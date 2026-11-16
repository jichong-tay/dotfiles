# Clink theme and prompt galleries

Researched 2026-11-16; no installation or configuration changes.

For less visual weight than Agnoster, **Pure** is the first native preset to
preview. The official gallery also shows Headline, Bureau, Darkblood, Jonathan,
and Antares. This is a visual recommendation; Git work still needs auditing.
The gallery provides rendered previews rather than standalone screenshots.
[Official previews](https://chrisant996.github.io/clink/clink.html#customprompts)

**Flex Prompt Lean** uses colored text without segment backgrounds; Classic
adds a gray background, while Rainbow uses colored backgrounds. It supplies Lua
scripts and a configuration wizard, including ASCII and two-line options.
[Options](https://github.com/chrisant996/clink-flex-prompt#style),
[actual screenshot](https://raw.githubusercontent.com/chrisant996/clink-flex-prompt/master/demo.png)

Native Lua does not guarantee zero subprocesses: Flex Prompt's Git module can
launch Git commands. For this laptop, omit Git/SCM modules and inspect any other
chosen module before adopting it.
[Module implementation](https://github.com/chrisant996/clink-flex-prompt/blob/master/flexprompt_modules.lua)

`.clinktheme` changes Clink's colors; `.clinkprompt` changes prompt layout.
Neither changes the whole terminal. Bundled palettes include Dracula,
Solarized, and Tomorrow variants. Starship and Oh My Posh integration require
their additional executables.
[Clink documentation](https://chrisant996.github.io/clink/clink.html#color-themes)

The [clink-themes repository](https://github.com/chrisant996/clink-themes)
collects community files, but its catalogue size was not verified here.
Keeping the existing single-file prompt and reducing its accents remains the
smallest option for the user's one-file, zero-Git-process preference.
