# Clink Lua loading diagnosis

Investigated 2026-11-17 against current upstream source and
[`clink/lean.lua`](../../clink/lean.lua). Laptop version, script paths, selected
prompt, and error output remain unknown; this is source analysis, not Windows
end-to-end verification.

## Confirmed defect

The original `getclinkprompt()` guards in `lean.lua` treated its first result as a boolean.
Upstream returns an **empty string** when no prompt is selected; that value is
truthy in Lua. Consequently both the Git-refresh handler and the custom prompt
filter returned immediately, even when no built-in prompt was active. Both
guards now use a shared nonempty-name check. [Prompt API implementation](https://github.com/chrisant996/clink/blob/master/clink/app/scripts/prompt.lua#L36-L59),
[empty basename behavior](https://github.com/chrisant996/clink/blob/master/clink/lua/src/path_api.cpp#L45-L50)

The regression test loads the real configuration with the documented empty-string
API result. It failed before the fix and passes afterwards under Lua and LuaJIT.
Run `lua tests/clink/prompt.lua` from the repo root. This checks our callback and
filter behavior, not Windows injection or the laptop's actual script paths.

## Other checks

- `settings.get()` returns booleans for booleans and strings for enums;
  `settings.set()` returns success and persists changes. The current helper's
  comparisons and assertions match those contracts. An unwritable settings
  file could still cause a visible load error; none has been captured.
  [Implementation](https://github.com/chrisant996/clink/blob/master/clink/lua/src/settings_api.cpp#L23-L167)
- `rl.setvariable()` returns success for valid variables. `editing-mode=emacs`
  and `keymap=emacs-standard` are valid upstream values. These calls are not a
  verified defect. [Lua wrapper](https://github.com/chrisant996/clink/blob/master/clink/lua/src/rl_api.cpp#L271-L297),
  [Readline setters and maps](https://github.com/chrisant996/clink/blob/master/readline/readline/bind.c#L2340-L2356)
- Current host initialization loads Readline first, then Lua scripts; it
  activates a selected `.clinkprompt` before `onbeginedit`. Yielding to an
  actually selected prompt is intentional behavior, distinct from the empty
  string defect. [Host order](https://github.com/chrisant996/clink/blob/master/clink/app/src/host/host.cpp#L896-L981)
- `clink.lua` is special: it is loaded only from the first script path and
  skipped during normal wildcard scanning. `lean.lua` follows normal scanning.
  [Loader](https://github.com/chrisant996/clink/blob/master/clink/app/src/host/host_lua.cpp#L154-L232)
- Git helpers require Clink 1.7.0+. Passing `true` to `git.getbranch()` requests
  the HEAD-reading path on modern versions; older versions already use it.
  The current fast call matches the subprocess constraint.
  [Git implementation](https://github.com/chrisant996/clink/blob/master/clink/app/scripts/git.lua#L460-L537)

Next laptop evidence: `clink_x64.exe info`, the selected-prompt settings or
environment override, and any Lua error. The empty-string defect is confirmed
independently of whether the laptop also has loading or injection problems.
