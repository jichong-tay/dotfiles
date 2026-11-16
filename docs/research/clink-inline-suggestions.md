# Clink inline history suggestions

Researched 2026-11-16; Windows runtime remains untested.

After `uv run` enters history, typing `uv` can show muted ` run`. Right accepts
it. Inline mode needs `autosuggest.enable` and, on current versions,
`autosuggest.inline`; the suggestion list must be inactive. F2 toggles that
list. The `history` strategy uses matching history; Tab completion is separate.
[Official documentation](https://chrisant996.github.io/clink/clink.html#inline-suggestions)

[Our Lua](../../clink/lean.lua) enables suggestions, leaves strategy/list defaults
inherited, and imports no Cmder history. Test with a newly executed command.
Autosuggestions require 1.2.47+.
[Changelog](https://chrisant996.github.io/clink/clink.html#v1.2.47)
