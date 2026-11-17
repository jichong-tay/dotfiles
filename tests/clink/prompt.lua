-- Run from the repository root: lua tests/clink/prompt.lua
-- Exercise the real configuration with Clink's documented getclinkprompt contract.
-- https://github.com/chrisant996/clink/blob/master/clink/app/scripts/prompt.lua

local function load_configuration(active_prompt, has_prompt_api, directory, input_color, environment)
    local callbacks, prompt = {}, nil
    local input_filters = {}
    local branch_reads = 0
    local exit_code = 0
    local color_writes = 0
    environment = environment or {}
    local values = {
        ["history.save"] = true,
        ["autosuggest.enable"] = true,
        ["clink.colorize_input"] = true,
        ["clink.promptfilter"] = true,
        ["clink.logo"] = "none",
        ["cmd.get_errorlevel"] = true,
        ["autosuggest.inline"] = true,
        ["match.coloring_rules"] = "di=38;2;86;156;214:ex=38;2;220;220;170",
        ["color.input"] = input_color,
    }
    local env = setmetatable({
        settings = {
            get = function(name) return values[name] end,
            parsecolor = function(color)
                assert(color == "#D4D4D4", "Only the supported fixture setting should be parsed")
                return "0;38;2;212;212;212"
            end,
            set = function(name, value)
                assert(name == "color.input" and value == "#D4D4D4",
                    "Unchanged settings should not be written")
                values[name] = "0;38;2;212;212;212"
                color_writes = color_writes + 1
                return true
            end,
        },
        rl = {
            setvariable = function() return true end,
            setbinding = function() return true end,
        },
        clink = {
            onbeginedit = function(callback) callbacks[#callbacks + 1] = callback end,
            onfilterinput = function(callback) input_filters[#input_filters + 1] = callback end,
            promptfilter = function() prompt = {}; return prompt end,
        },
        git = {
            getgitdir = function() return [[C:\repo\.git]] end,
            getbranch = function(_, fast)
                assert(fast == true, "Branch lookup must avoid git.exe")
                branch_reads = branch_reads + 1
                return "main", false
            end,
        },
        os = {
            getcwd = function() return directory or [[C:\repo]] end,
            geterrorlevel = function() return exit_code end,
            getenv = function(name) return environment[name] end,
        },
    }, { __index = _G })

    if has_prompt_api then
        env.clink.getclinkprompt = function()
            -- Clink returns three EMPTY STRINGS and a table when inactive.
            return active_prompt, active_prompt, active_prompt, {}
        end
    end

    local chunk
    if setfenv then
        chunk = assert(loadfile("clink/lean.lua"))
        setfenv(chunk, env)
    else
        chunk = assert(loadfile("clink/lean.lua", "t", env))
    end
    chunk()
    for _, callback in ipairs(callbacks) do callback() end
    return prompt, function() return branch_reads end,
        function(value) exit_code = value end,
        function() return color_writes end,
        function(line)
            for _, callback in ipairs(input_filters) do
                local replacement, continue_filtering = callback(line)
                if replacement ~= nil then line = replacement end
                if continue_filtering == false then break end
            end
            return line
        end
end

local function assert_lean_prompt(active_prompt, has_prompt_api)
    local prompt, branch_reads = load_configuration(active_prompt, has_prompt_api)
    local rendered, continue_filtering = prompt:filter()
    assert(type(rendered) == "string", "Lean prompt must render when no preset is active")
    assert(rendered:gsub("\27%[[%d;]*m", "") == "C:\\repo  ·   main\n❯ ")
    assert(continue_filtering == false)
    assert(branch_reads() == 1, "Git branch must refresh when no preset is active")
    prompt:filter()
    assert(branch_reads() == 1, "Prompt redraw must reuse the branch")
end

assert_lean_prompt("", true)
assert_lean_prompt(nil, true)
assert_lean_prompt(nil, false)

local prompt, branch_reads = load_configuration("agnoster", true)
assert(prompt:filter() == nil, "A selected preset must retain its prompt")
assert(branch_reads() == 0, "A selected preset must not trigger our branch reader")

local status_prompt, _, set_exit_code = load_configuration("", true)
local success = status_prompt:filter()
set_exit_code(7)
local failure = status_prompt:filter()
assert(success ~= failure, "A failed command must change the prompt symbol's appearance")
assert(success:gsub("\27%[[%d;]*m", "") == failure:gsub("\27%[[%d;]*m", ""),
    "Exit status must not change the displayed path or branch")

for _, directory in ipairs({ [[C:\]], [[C:\Users\Test User\projects]], [[\\server\share]], [[\\server\share\]] }) do
    local path_prompt = load_configuration("", true, directory)
    local rendered = path_prompt:filter()
    local plain = rendered:gsub("\27%[[%d;]*m", "")
    assert(plain:sub(1, #directory) == directory, "Directory formatting must preserve the complete path")
end

-- Native color settings return normalized SGR, not the saved RGB spelling.
local _, _, _, changed_writes = load_configuration("", true, nil, "")
assert(changed_writes() == 1, "A different supported color must be applied")
local _, _, _, unchanged_writes = load_configuration("", true, nil, "0;38;2;212;212;212")
assert(unchanged_writes() == 0, "Normalized colors must not be rewritten at startup")

-- Activation changes CMD's PROMPT, but our replacement must display the active
-- environment itself. Omitting it (the original bug) fails this real filter.
local environment = { VIRTUAL_ENV = [[C:\projects\analytics\.venv]] }
local env_prompt, env_branch_reads = load_configuration("", true, nil, nil, environment)
local function plain_environment_prompt()
    local rendered = env_prompt:filter("(.venv) C:\\repo> ")
    return rendered:gsub("\27%[[%d;]*m", "")
end
assert(plain_environment_prompt() == "C:\\repo  ·   main  ·  (.venv)\n❯ ",
    "An activated Python environment must appear in the custom prompt")

environment.VIRTUAL_ENV_PROMPT = "data science"
assert(plain_environment_prompt():find("(data science)", 1, true), "Honor a custom environment name")
environment.VIRTUAL_ENV_PROMPT = "(data science) "
assert(plain_environment_prompt():find("(data science)", 1, true), "Normalize older wrapped prompt names")
assert(not plain_environment_prompt():find("((data science))", 1, true), "Do not double-wrap the label")
environment.VIRTUAL_ENV_PROMPT = ""
environment.VIRTUAL_ENV = [[C:\Users\Test User\my env\]]
assert(plain_environment_prompt():find("(my env)", 1, true), "Handle spaces and trailing path separators")

environment.VIRTUAL_ENV = nil
environment.VIRTUAL_ENV_PROMPT = "stale label"
assert(plain_environment_prompt() == "C:\\repo  ·   main\n❯ ",
    "Deactivation must hide the label, even if a prompt name remains")
environment.CONDA_PREFIX = [[C:\tools\miniconda\envs\analysis]]
environment.CONDA_DEFAULT_ENV = "analysis"
assert(plain_environment_prompt():find("(analysis)", 1, true), "Show an activated Conda environment")
environment.VIRTUAL_ENV = [[C:\repo\.venv]]
environment.VIRTUAL_ENV_PROMPT = ".venv"
assert(plain_environment_prompt():find("(.venv)", 1, true), "A nested venv takes precedence over Conda")
assert(not plain_environment_prompt():find("(analysis)", 1, true), "Show only the active inner environment")
assert(env_branch_reads() == 1, "Environment changes must not add Git metadata reads on redraw")

local _, _, _, _, filter_input = load_configuration("", true)
for _, command in ipairs({ "cd ~", "CD ~", "  cd\t~  ", "cd /d ~", "CD /D ~" }) do
    assert(filter_input(command) == [[cd /d "%USERPROFILE%"]],
        "The standalone home shortcut must use the quoted user profile and switch drives")
end
for _, command in ipairs({ "cd projects", "echo cd ~", "cd ~ & echo done", "cd ~\\Documents", "cd ~~", "" }) do
    assert(filter_input(command) == command, "Other commands must pass through unchanged: " .. command)
end

print("Passed: presets, Git, exit status, paths, colors, Python environments, and the cd ~ shortcut.")
