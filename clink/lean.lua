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
configure("clink.promptfilter", true)
configure("clink.logo", "none")

-- Older Clink versions enable inline suggestions without this setting.
if settings.get("autosuggest.inline") ~= nil then
    configure("autosuggest.inline", true)
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

-- Lean layout with a blue path, subdued branch, and green input marker.
-- Tokyo Night palette; no background colors, frames, or segment separators.
local cwd_color = "\27[38;2;122;162;247m" -- #7AA2F7
local git_color = "\27[38;2;154;165;206m" -- #9AA5CE
local symbol_color = "\27[38;2;158;206;106m" -- #9ECE6A
local reset = "\27[0m"
local symbol = use_nerd_font and "❯" or ">"
local branch_icon = use_nerd_font and " " or "git:"

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
    git_text = "   " .. git_color .. branch_icon .. branch .. reset
end)

local prompt = clink.promptfilter(30)

function prompt:filter()
    -- Let an explicitly selected built-in .clinkprompt take over the layout.
    if has_selected_prompt() then return end
    return reset .. cwd_color .. os.getcwd() .. reset .. git_text
        .. "\n" .. symbol_color .. symbol .. reset .. " ", false
end
