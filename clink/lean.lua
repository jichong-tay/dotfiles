-- All custom Clink configuration lives here; no .inputrc is required.
-- Keep the name lean.lua; clink.lua is a special compatibility filename.
-- Put this file in ONE script directory listed by clink_x64.exe info.
-- Requires Clink 1.7.0 or newer with the Git prompt enabled. No subprocesses.
-- Standalone adaptation of Flex Prompt's Lean look: colored text, no panels.

local show_git = true
local use_nerd_font = true -- Set false if a Nerd Font is unavailable.

local function has_selected_prompt()
    local name = clink.getclinkprompt and clink.getclinkprompt()
    -- Clink returns an empty string when inactive; empty strings are truthy in Lua.
    return name ~= nil and name ~= ""
end

-- settings.set persists changes, so avoid writing unchanged values.
local function configure(name, value)
    local current = settings.get(name)
    assert(current ~= nil, "Clink setting unavailable: " .. name)
    if current ~= value then
        assert(settings.set(name, value), "Unable to set Clink setting: " .. name)
    end
end

configure("history.save", true)
configure("autosuggest.enable", true)
configure("clink.colorize_input", true)
configure("clink.promptfilter", true)
configure("clink.logo", "none")
configure("cmd.get_errorlevel", true)

-- Older Clink versions enable inline suggestions without this setting.
if settings.get("autosuggest.inline") ~= nil then
    configure("autosuggest.inline", true)
end

-- Native colors only: applied at script load, with no new editing hooks.
-- Clink 1.7+ parses RGB colors; leave older versions' colors alone.
if settings.parsecolor then
    local colors = {
        ["color.input"] = "#D4D4D4",
        ["color.arg"] = "#D4D4D4",
        ["color.cmd"] = "#DCDCAA",
        ["color.executable"] = "#DCDCAA",
        ["color.argmatcher"] = "#DCDCAA",
        ["color.doskey"] = "#4EC9B0",
        ["color.flag"] = "#569CD6",
        ["color.cmdredir"] = "#C586C0",
        ["color.cmdsep"] = "#C586C0",
        ["color.unrecognized"] = "#CE9178",
        ["color.suggestion"] = "#808080",
        ["color.description"] = "#808080",
        ["color.arginfo"] = "#9CDCFE",
        ["color.common_match_prefix"] = "#9CDCFE",
        ["color.selected_completion"] = "#D4D4D4 on #264F78",
        ["color.selection"] = "#D4D4D4 on #264F78",
        ["color.comment_row"] = "#808080",
        ["color.popup"] = "#D4D4D4 on #1E1E1E",
        ["color.popup_border"] = "#808080 on #1E1E1E",
        ["color.popup_desc"] = "#808080 on #1E1E1E",
        ["color.popup_select"] = "#D4D4D4 on #264F78",
        ["color.popup_selectdesc"] = "#9CDCFE on #264F78",
    }
    for name, color in pairs(colors) do
        local current = settings.get(name)
        -- Skip settings absent in this Clink version. Compare normalized SGR,
        -- because settings.get returns ANSI codes rather than the RGB spelling.
        if current ~= nil and current ~= assert(settings.parsecolor(color)) then
            assert(settings.set(name, color), "Unable to set Clink color: " .. name)
        end
    end
    configure("match.coloring_rules", "di=38;2;86;156;214:ex=38;2;220;220;170")
end

-- Apply after Readline initialization, once per script load (including reloads).
local initialized = false
clink.onbeginedit(function()
    if initialized then return end

    local function variable(name, value)
        assert(rl.setvariable(name, value), "Unable to set Readline variable: " .. name)
    end
    local function bind(key, command)
        assert(rl.setbinding(key, command, "emacs"), "Unable to bind key: " .. key)
    end

    variable("editing-mode", "emacs")
    variable("keymap", "emacs-standard")
    variable("completion-ignore-case", "on")
    variable("show-all-if-ambiguous", "on")
    variable("colored-stats", "on")
    variable("colored-completion-prefix", "on")
    variable("mark-directories", "on")

    bind([["\e[A"]], "history-search-backward")
    bind([["\e[B"]], "history-search-forward")
    bind([["\C-r"]], "reverse-search-history")
    bind([["\C-a"]], "beginning-of-line")
    bind([["\C-e"]], "end-of-line")
    bind([["\C-w"]], "unix-word-rubout")
    bind([["\eb"]], "backward-word")
    bind([["\ef"]], "forward-word")
    initialized = true
end)

-- Silver & steel prompt with VS Code inspired input colors. No panels or frame.
local parent_color = "\27[38;2;128;128;128m" -- #808080
local cwd_color = "\27[38;2;184;184;184m" -- soft silver #B8B8B8, normal weight
local git_color = "\27[38;2;143;163;184m" -- muted steel #8FA3B8
local symbol_color = "\27[38;2;215;186;125m" -- warm gold #D7BA7D
local error_color = "\27[38;2;244;71;71m" -- #F44747
local reset = "\27[0m"
local symbol = use_nerd_font and "❯" or ">"
local branch_icon = use_nerd_font and " " or "git:"
local separator = use_nerd_font and "  ·  " or "  |  "

local function format_directory()
    local cwd = os.getcwd()
    local parent, folder = cwd:match("^(.*[\\/])([^\\/]+)$")
    if not parent then
        -- Preserve drive roots and paths ending in a slash verbatim.
        return cwd_color .. cwd .. reset
    end
    return parent_color .. parent .. reset .. cwd_color .. folder .. reset
end

local function format_environment()
    -- Activation scripts set these in CMD. Read them at render time so activate,
    -- deactivate, and environment switches appear immediately, without a process
    -- launch or filesystem scan. A nested venv takes precedence over Conda.
    local prefix = os.getenv("VIRTUAL_ENV")
    local name = os.getenv("VIRTUAL_ENV_PROMPT")
    if not prefix or prefix == "" then
        prefix = os.getenv("CONDA_PREFIX")
        name = os.getenv("CONDA_DEFAULT_ENV")
    end
    if not prefix or prefix == "" then return "" end

    if name then
        name = name:gsub("[%c]", ""):match("^%s*(.-)%s*$")
        -- Older activators include parentheses and trailing space in the name.
        name = name:match("^%((.*)%)$") or name
    end
    if not name or name == "" then
        name = prefix:gsub("[\\/]+$", ""):match("([^\\/]+)$")
    end
    if not name or name == "" then return "" end

    return parent_color .. separator .. reset .. git_color .. "(" .. name .. ")" .. reset
end

if show_git then
    assert(git and git.getgitdir and git.getbranch,
        "Git prompt requires Clink 1.7.0 or newer; alternatively set show_git = false")
end

-- Refresh once per editing session, so redraws do not read Git metadata again.
local git_text = ""
clink.onbeginedit(function()
    git_text = ""
    if not show_git then return end
    if has_selected_prompt() then return end

    local git_dir = git.getgitdir()
    if not git_dir then return end

    -- IMPORTANT: true requests a HEAD file read, never the git.exe fallback.
    local branch, detached = git.getbranch(git_dir, true)
    if not branch or branch == "" then return end
    if branch == ".invalid" then
        -- Reftable storage needs git.exe for the name; keep the fast-only rule.
        branch = "(branch unavailable)"
    elseif detached then
        branch = "@" .. branch
    end
    git_text = parent_color .. separator .. reset .. git_color .. branch_icon .. branch .. reset
end)

local prompt = clink.promptfilter(30)

function prompt:filter()
    -- Let an explicitly selected built-in .clinkprompt take over the layout.
    if has_selected_prompt() then return end
    local marker_color = os.geterrorlevel() == 0 and symbol_color or error_color
    return reset .. format_directory() .. git_text .. format_environment()
        .. "\n" .. marker_color .. symbol .. reset .. " ", false
end
