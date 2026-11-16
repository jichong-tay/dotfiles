# Clink: Lean style in one Lua file

`lean.lua` contains the prompt, Git branch, Nerd Font icons, completion
preferences, history settings, and keyboard shortcuts. No `.inputrc`, PowerShell, extra runtime, or administrator
access is required. Clink still stores its own settings and history files.

```text
C:\projects\analytics  ·   main
❯ _
```

This is a standalone adaptation of [Flex Prompt's Lean style](https://github.com/chrisant996/clink-flex-prompt#style):
colored text on two lines, with a subtle separator between the directory and
branch. The prompt uses a Silver & steel palette: gray parent folders and separator
(`#808080`), a soft silver current folder (`#B8B8B8`, normal weight), a muted steel Git branch
(`#8FA3B8`), and a warm gold input marker (`#D7BA7D`). The marker turns red after
a failed command. Input colors
are inspired by [VS Code Dark+](https://github.com/microsoft/vscode/blob/main/extensions/theme-defaults/themes/dark_plus.json). The single-file
implementation keeps the branch-only Git reader and needs no Flex Prompt package
or configuration wizard.

Git metadata is read without launching `git.exe`. Set `use_nerd_font = false`
at the top of the Lua file for plain-text symbols, or `show_git = false` to
disable repository detection. The Nerd Font branch icon remains enabled by
default; there is no folder icon, frame, colored panel, or time display.

Clink's built-in input colors retain the VS Code inspired palette: soft yellow commands,
teal aliases, blue flags, gray suggestions and completion descriptions, and blue
directories in completion lists. Selected completions and popup history entries
use a dark blue highlight. Flag and argument coloring depends on the command's
available argmatcher; no extra completion scripts are installed.

These are native color settings applied when Lua loads, with no additional
prompt hooks, subprocesses, or Git status scans. Unchanged settings are not
rewritten. Windows Terminal's palette and command output are unchanged. RGB
input styling requires Clink 1.7 or newer; older versions keep their input colors.

## 1. Check your Windows installation

Open a fresh CMD tab in Windows Terminal and run:

```cmd
"%USERPROFILE%\tools\clink\clink_x64.exe" --version
"%USERPROFILE%\tools\clink\clink_x64.exe" autorun show
"%USERPROFILE%\tools\clink\clink_x64.exe" info
```

Use Clink 1.7.0 or newer for the native Git API. With `show_git = false`, the
other features need 1.2.47 or newer. Save the output and back up the settings
file reported by `info`. Confirm that `binaries` points to this
standalone installation and that `scripts` includes
`%USERPROFILE%\tools\clink`. If that folder is absent, use an actual script
directory listed by `info` as the copy destination in step 2.

### Install or uninstall AutoRun

AutoRun starts Clink automatically in new CMD sessions. If `autorun show`
already points to this installation, skip the install command. Inspect any
old Cmder references and preserve unrelated startup commands.

To enable AutoRun for your user account, run in regular CMD:

```cmd
"%USERPROFILE%\tools\clink\clink_x64.exe" autorun install
"%USERPROFILE%\tools\clink\clink_x64.exe" autorun show
```

Open a new CMD tab afterwards. Do not add another injection command to your
Windows Terminal profile. CMD launched with `/d` bypasses AutoRun.

To disable automatic Clink startup:

```cmd
"%USERPROFILE%\tools\clink\clink_x64.exe" autorun uninstall
"%USERPROFILE%\tools\clink\clink_x64.exe" autorun show
```

Existing CMD sessions keep Clink until closed. Uninstalling AutoRun does not
delete `lean.lua` or saved history. See [Clink's AutoRun usage](https://chrisant996.github.io/clink/#usage)
or run `"%USERPROFILE%\tools\clink\clink_x64.exe" autorun --help` for available
options.

## 2. Copy one file

From the **dotfiles repository root on Windows**, run:

```cmd
copy /-Y "clink\lean.lua" "%USERPROFILE%\tools\clink\lean.lua"
```

Keep the portable package's existing `clink.lua` file. It is an intentionally
blank compatibility file; our custom configuration must be named `lean.lua`.
Clink treats `clink.lua` specially and skips that name during normal script
discovery. See the [bundled file](https://github.com/chrisant996/clink/blob/master/clink/app/src/loader/clink.lua)
and [script loader](https://github.com/chrisant996/clink/blob/master/clink/app/src/host/host_lua.cpp#L154-L232).

Alternatively, copy `lean.lua` using File Explorer. Keep the Clink installation
and its DLLs together. Do not overwrite an existing custom Lua file without
backing it up.

Keep only one copy of `lean.lua` loaded.
If you previously registered the repo folder with `installscripts`, remove
that registration before also loading a copied file. From the repo root:

```cmd
"%USERPROFILE%\tools\clink\clink_x64.exe" uninstallscripts "%CD%\clink"
```

Skip that command if you never registered the folder. Back up and disable
other prompt scripts or selected custom prompts that compete with this one.
Stopping later prompt filters cannot prevent earlier scripts from doing work.

You do not need to create or copy `.inputrc`. If you installed the earlier
version solely for Clink, restore your original file or move that Clink-only
file aside. Preserve any inputrc settings needed by other programs.

## 3. Open a new CMD tab

The Lua file enables persistent history and autosuggestions, hides Clink's
logo, and installs the shortcuts below. Newer versions' separate inline
suggestion setting is enabled when available.

Clink settings are saved only when their values differ. The Lua file remains
the source of your preferences and reapplies them when loaded. Readline
preferences and bindings are applied once at the first editing prompt after
each script load. There are no setting writes in the prompt-rendering function.
These use Clink's native [settings and Readline APIs](https://chrisant996.github.io/clink/clink.html#settings.set).

The first session may still show Clink's logo before Lua changes the saved
setting; check another fresh tab. Windows CMD's banner and Cmder messages
are separate. Keep startup errors visible.

| Keys | Action |
| --- | --- |
| Up / Down | Search history by the prefix before the cursor |
| Ctrl+R | Reverse history search |
| Ctrl+A / Ctrl+E | Beginning / end of line |
| Ctrl+W | Delete previous word |
| Alt+B / Alt+F | Move backward / forward one word |
| Tab | Completion |

With an empty prefix, Up and Down browse ordinary history. The file explicitly
selects Emacs editing mode for these bindings.

## 4. Use CMD in Windows Terminal

Windows Terminal's CMD profile should launch `cmd.exe` without `/d` and without
another Clink injection command. `/d` bypasses AutoRun. Start with a dark color
scheme, modest padding, and acrylic disabled.

## Git information

The prompt shows the branch, or `@` followed by the abbreviated commit when
HEAD is detached. It refreshes at each new input prompt, including after a
branch switch. Redraws reuse the result. Repository discovery checks parent
directories; it does not scan all project files.

The script calls `git.getbranch(git_dir, true)` deliberately: on newer Clink,
omitting `true` can launch `git.exe`. Fast mode reads HEAD directly. For Git's
reftable storage, it displays `(branch unavailable)` rather than falling back
to a subprocess. See the [native Git API](https://chrisant996.github.io/clink/clink.html#git.getbranch).

Dirty-file counts and ahead/behind counts are not collected. If repository
metadata lives on a slow network drive, set `show_git = false` to avoid those
filesystem checks too.

## Install a Nerd Font without administrator access

1. Download **CaskaydiaMono** from the [official font downloads](https://www.nerdfonts.com/font-downloads).
   It is the patched Cascadia Mono family. Extract the archive in File Explorer.
2. Select the Regular `.ttf` file for the **Nerd Font Mono** variant, and
   optionally Bold/Italic. Right-click and choose **Install**, not **Install for
   all users**. This targets your account; corporate policy can still prevent
   font installation.
3. Restart Windows Terminal. Open **Settings → your CMD profile → Appearance →
   Font face** and select the installed **CaskaydiaMono Nerd Font Mono** family
   (use the exact name shown in the font list). Save.

Windows Terminal stores this under its profile's `font.face` setting; see
[Microsoft's appearance settings](https://learn.microsoft.com/en-us/windows/terminal/customize-settings/profile-appearance#font-face).
If icons show as boxes or overlap, verify the selected family or set
`use_nerd_font = false`. Save `lean.lua` as UTF-8 after editing it.

## Migrate Cmder history

Clink has no `history import` command. These steps copy its history as data;
they never replay saved commands. The simplest method below replaces the
standalone history with Cmder's history while keeping a backup of both. It
does not merge the two lists.

1. In your old Cmder session, run `clink info` and record its **history** path.
   Normally it is `config\clink_history` under Cmder, but custom config paths
   and history labels can change it. In standalone CMD, run
   `"%USERPROFILE%\tools\clink\clink_x64.exe" info` and record that history
   path too. Use these actual paths rather than guessing from the install dir.
   Cmder uses its own [Clink profile directory](https://github.com/cmderdev/cmder/blob/master/vendor/init.bat).
2. Close all Cmder and Clink sessions normally so their history finishes saving. Press **Win+R**, enter
   `cmd.exe /d`, and press Enter. This is a temporary maintenance shell with
   AutoRun disabled; keep it uninjected during copying.
3. Replace the two example paths below with the recorded full filenames.
   Create a fresh backup folder; if this backup name already exists, choose a
   new name before continuing. Run each command separately, and stop if any
   copy fails:

   ```cmd
   set "CLINK_OLD_HISTORY=C:\actual\cmder\config\clink_history"
   set "CLINK_NEW_HISTORY=C:\actual\standalone\profile\clink_history"
   set "CLINK_MIGRATION_BACKUP=%USERPROFILE%\clink-history-backup"
   mkdir "%CLINK_MIGRATION_BACKUP%"
   copy /-Y "%CLINK_OLD_HISTORY%" "%CLINK_MIGRATION_BACKUP%\cmder-history.original"
   if exist "%CLINK_NEW_HISTORY%" copy /-Y "%CLINK_NEW_HISTORY%" "%CLINK_MIGRATION_BACKUP%\standalone-history.original"
   copy /-Y "%CLINK_MIGRATION_BACKUP%\cmder-history.original" "%CLINK_NEW_HISTORY%"
   ```

4. Close the maintenance shell. Open a regular CMD tab and use Ctrl+R to find
   a known old command. Then type `uv` and check suggestions. The configured
   history size limit still applies. Keep both backups until verified; restore
   `standalone-history.original` with all Clink sessions closed to undo.

## Other color themes and prompt layouts

Current Clink includes color themes such as **Dracula**, **Solarized**, and
**Tomorrow**, plus prompt layouts such as **agnoster**, **Headline**, **Antares**,
and **darkblood**. List what your installed version actually includes:

```cmd
"%USERPROFILE%\tools\clink\clink_x64.exe" config theme list
"%USERPROFILE%\tools\clink\clink_x64.exe" config prompt list
```

To preview an installed option without selecting it:

```cmd
"%USERPROFILE%\tools\clink\clink_x64.exe" config theme show Dracula
"%USERPROFILE%\tools\clink\clink_x64.exe" config prompt show agnoster
```

Color themes affect Clink's input/completion colors. This Lua file reapplies its
VS Code inspired input colors on load; remove its native-colors block to keep a
different Clink theme. The prompt palette is explicit and is not replaced by a
Clink color theme. Windows Terminal controls the background and terminal palette
separately.

The Lua prompt yields when a `.clinkprompt` is explicitly selected, retaining
its history/keybinding setup. Such a prompt may collect Git status using
subprocesses; its own implementation determines the cost. Our custom prompt's
fast-only Git behavior does not extend to other prompt scripts. See
[Clink's theme and prompt guide](https://chrisant996.github.io/clink/clink.html#custom-prompts).

## Undo

Move the copied `lean.lua` out of the script directory, restore your settings
backup, and open a fresh CMD tab. Lua changes Clink's saved settings, so removing
the script alone does not revert those settings. Your history and existing
Clink AutoRun installation can remain in place.
