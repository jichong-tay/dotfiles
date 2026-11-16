-- Run from the repository root: lua tests/clink/prompt.lua
-- Exercise the real configuration with Clink's documented getclinkprompt contract.
-- https://github.com/chrisant996/clink/blob/master/clink/app/scripts/prompt.lua

local function load_configuration(active_prompt, has_prompt_api)
    local callbacks, prompt = {}, nil
    local branch_reads = 0
    local values = {
        ["history.save"] = true,
        ["autosuggest.enable"] = true,
        ["clink.promptfilter"] = true,
        ["clink.logo"] = "none",
        ["autosuggest.inline"] = true,
    }
    local env = setmetatable({
        settings = {
            get = function(name) return values[name] end,
            set = function() error("Unchanged settings should not be written") end,
        },
        rl = {
            setvariable = function() return true end,
            setbinding = function() return true end,
        },
        clink = {
            onbeginedit = function(callback) callbacks[#callbacks + 1] = callback end,
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
        os = { getcwd = function() return [[C:\repo]] end },
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
    return prompt, function() return branch_reads end
end

local function assert_lean_prompt(active_prompt, has_prompt_api)
    local prompt, branch_reads = load_configuration(active_prompt, has_prompt_api)
    local rendered, continue_filtering = prompt:filter()
    assert(type(rendered) == "string", "Lean prompt must render when no preset is active")
    assert(rendered:gsub("\27%[[%d;]*m", "") == "C:\\repo    main\n❯ ")
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

print("Passed: inactive empty-string prompt, compatibility cases, active preset, and Git refresh.")
