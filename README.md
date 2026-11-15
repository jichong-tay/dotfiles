# dotfiles
My personal development environment configurations

## Keep the local Neovim config in sync

The repository is the source of truth. Make config changes here, then run this from the repository root to sync them to Neovim:

```sh
mkdir -p ~/.config/nvim
rsync -av --delete nvim/ ~/.config/nvim/
rsync -av ~/.config/nvim/ nivm/
```

The `--delete` option removes files from `~/.config/nvim` that are not in the repository. Back up an existing local config before the first sync. Avoid making changes only in `~/.config/nvim`; make them in  this repository and sync again.

## Set up Neovim on Windows

Use Neovim 0.12 or newer and Git. Close Neovim, back up any existing `%LOCALAPPDATA%\nvim` folder, then use File Explorer to paste `init.lua`, `lua\`, and `nvim-pack-lock.windows.json` into `%LOCALAPPDATA%\nvim`. Rename the copied lockfile to **`nvim-pack-lock.json`** before starting Neovim. The Windows lockfile omits Mason, its two companion plugins, and LuaSnip. Blink uses Neovim's built-in snippet engine on Windows.

If these plugins were previously installed, move `mason.nvim`, `mason-lspconfig.nvim`, `mason-tool-installer.nvim`, and `LuaSnip` out of `%LOCALAPPDATA%\nvim-data\site\pack\core\opt` before first launch with the new lockfile. `vim.pack` records plugin folders it finds there.

At startup, `vim.pack` can download the plugins from GitHub. For an offline laptop, copy the plugin folders from a matching Windows setup into `%LOCALAPPDATA%\nvim-data\site\pack\core\opt`, including each plugin's `.git` folder. Use Windows builds for tools on `PATH` and any prebuilt parsers (`nvim-data\site\parser`, with `site\queries` if present).

### Portable build tools

- **GCC and Make:** Extract [w64devkit](https://github.com/skeeto/w64devkit/releases) to `%USERPROFILE%\.local\w64devkit` on an x64 Windows PC. Keep the whole kit together.
- **Treesitter:** Extract the matching [Windows Tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/releases) as `tree-sitter.exe` into `%USERPROFILE%\.local\bin`.
- **ZIP files:** Use **Extract All** in File Explorer, or run `tar -xf archive.zip` in CMD with [Windows' built-in tar](https://learn.microsoft.com/en-us/windows/tar/).

In a regular CMD window, set the paths and launch Neovim from that same window. This requires no permanent PATH change.

```cmd
set "PATH=%USERPROFILE%\.local\w64devkit\bin;%USERPROFILE%\.local\bin;%PATH%"
where gcc make tree-sitter
nvim
```

If Tree-sitter picks the wrong compiler, run `set "CC=gcc"` in that CMD window before launching Neovim.

If you can't run the portable build tools, use prebuilt Windows parsers or leave the local parser checkout folders absent. Run `:checkhealth` after starting Neovim.

### Build Telescope's native sorter if Make hangs

If `make` opens a nested Command Prompt during `cmd /C mkdir build`, type `exit` to leave that prompt. Close Neovim, then open a regular CMD window. With the plugin already installed, build its DLL directly:

```cmd
set "PATH=%USERPROFILE%\.local\w64devkit\bin;%PATH%"
pushd "%LOCALAPPDATA%\nvim-data\site\pack\core\opt\telescope-fzf-native.nvim"
if not exist build mkdir build
gcc -O3 -Wall -std=gnu99 -shared src\fzf.c -o build\libfzf.dll
popd
```

Launch Neovim from that CMD window and run `:checkhealth telescope`. In the `fzf` section, look for `lib working as expected` and both sorters marked `correctly configured`. Treesitter also compiles native code, but its local parser builds use `tree-sitter.exe` and GCC directly.

### Set up Lua Language Server without PowerShell

Windows uses manually installed language servers. Download the ZIP for your laptop's architecture from [Lua Language Server releases](https://github.com/LuaLS/lua-language-server/releases). Use **Extract All** in File Explorer to extract it to `%USERPROFILE%\.local\lua-language-server`. Keep the extracted files together.

In the same CMD window you use to launch Neovim, add the folder containing `lua-language-server.exe` to `PATH`:

```cmd
set "PATH=%USERPROFILE%\.local\lua-language-server\bin;%PATH%"
where lua-language-server
nvim "%LOCALAPPDATA%\nvim\init.lua"
```

If your ZIP extracted into an extra subfolder, adjust the `PATH` entry to match. In Neovim, run `:checkhealth vim.lsp` and look for `lua_ls` under active clients.

### Set up Go without Mason

With `go.exe` on `PATH`, install `gopls` from CMD using the [Go project's installation instructions](https://go.dev/gopls/#installation):

```cmd
set "GOBIN=%USERPROFILE%\.local\bin"
go install golang.org/x/tools/gopls@latest
set "PATH=%GOBIN%;%PATH%"
gopls version
```

Launch Neovim from that CMD window, open a `.go` file in your project, and check for `gopls` in `:checkhealth vim.lsp`. The config also recognises `.gotmpl` and `.gotmpls` as Go templates.

### Set up Tailwind CSS without Mason

With Node.js and npm on `PATH`, install the [Tailwind CSS language server](https://github.com/tailwindlabs/tailwindcss-intellisense/tree/main/packages/tailwindcss-language-server) into your user folder from CMD:

```cmd
npm.cmd install --global --prefix "%USERPROFILE%\.local\tailwindcss" @tailwindcss/language-server
```

The Windows config runs this copy through `node`. Open an HTML, JSX, TSX, or CSS file in a project that uses Tailwind and check for `tailwindcss` under **Active Clients** in `:checkhealth vim.lsp`.

### Render Markdown

Open a `.md` file to render headings, tables, checkboxes, and code blocks inside Neovim. Press **Space t m** to toggle rendering. The line under the cursor shows its Markdown source for editing. The config uses plain characters when `vim.g.have_nerd_font` is false. Rendering uses the `markdown` and `markdown_inline` parsers, which are already listed in this config. On Windows, use the local checkouts described below or copy compatible prebuilt parsers and their queries from a matching Windows setup.

See the [render-markdown documentation](https://github.com/MeanderingProgrammer/render-markdown.nvim) for rendering options.

### Install Treesitter parsers from local Git checkouts

On the work laptop, `curl` fails with the Schannel error `CRYPT_E_NO_REVOCATION_CHECK`. On Windows, this config only auto-installs parsers from local Git checkouts and skips the automatic `:TSUpdate` hook. Installed and bundled parsers are still usable. Run `:TSInstall` only for parsers with a local checkout, since explicit install or update commands can still download files.

If Git can reach GitHub, clone the parsers you need in CMD. These revisions match this repo's pinned `nvim-treesitter` version. Skip the clone command for any parser you already cloned.

```cmd
git clone https://github.com/neovim/tree-sitter-vimdoc.git "%USERPROFILE%\.local\parsers\vimdoc"
git -C "%USERPROFILE%\.local\parsers\vimdoc" checkout a13c5c7e09aa2ec2f724ac5c0fdb91a4a7eeabba
git clone https://github.com/tree-sitter-grammars/tree-sitter-diff.git "%USERPROFILE%\.local\parsers\diff"
git -C "%USERPROFILE%\.local\parsers\diff" checkout ada384ac7bfc1307f32de474620120add29998fb
git clone https://github.com/tree-sitter/tree-sitter-bash.git "%USERPROFILE%\.local\parsers\bash"
git -C "%USERPROFILE%\.local\parsers\bash" checkout a06c2e4415e9bc0346c6b86d401879ffb44058f7
git clone https://github.com/tree-sitter/tree-sitter-html.git "%USERPROFILE%\.local\parsers\html"
git -C "%USERPROFILE%\.local\parsers\html" checkout 73a3947324f6efddf9e17c0ea58d454843590cc0
git clone https://github.com/tree-sitter/tree-sitter-c.git "%USERPROFILE%\.local\parsers\c"
git -C "%USERPROFILE%\.local\parsers\c" checkout b780e47fc780ddc8da13afa35a3f4ed5c157823d
git clone https://github.com/tree-sitter-grammars/tree-sitter-luadoc.git "%USERPROFILE%\.local\parsers\luadoc"
git -C "%USERPROFILE%\.local\parsers\luadoc" checkout 4d04632a3a398b78af52e83be074883e722f40be
git clone https://github.com/tree-sitter-grammars/tree-sitter-lua.git "%USERPROFILE%\.local\parsers\lua"
git -C "%USERPROFILE%\.local\parsers\lua" checkout 10fe0054734eec83049514ea2e718b2a56acd0c9
git clone https://github.com/tree-sitter-grammars/tree-sitter-markdown.git "%USERPROFILE%\.local\parsers\markdown"
git -C "%USERPROFILE%\.local\parsers\markdown" checkout 41ff24a6c775492c543b09228aeb98d1cd2b3a0f
git clone https://github.com/tree-sitter-grammars/tree-sitter-query.git "%USERPROFILE%\.local\parsers\query"
git -C "%USERPROFILE%\.local\parsers\query" checkout 8e9e223812ff30854fbc912adbec696ba5f0e023
git clone https://github.com/tree-sitter-grammars/tree-sitter-vim.git "%USERPROFILE%\.local\parsers\vim"
git -C "%USERPROFILE%\.local\parsers\vim" checkout 039c8d0aa1deae00ddeb0374dd70bcc0ec56938d
git clone https://github.com/tree-sitter/tree-sitter-python.git "%USERPROFILE%\.local\parsers\python"
git -C "%USERPROFILE%\.local\parsers\python" checkout v0.25.0
git clone https://github.com/cathaysia/tree-sitter-jinja.git "%USERPROFILE%\.local\parsers\jinja"
git -C "%USERPROFILE%\.local\parsers\jinja" checkout c213d3745ccdcaaa858869181c7b1bf9557a025f
```

The Markdown checkout supplies both `markdown` and `markdown_inline`. Retry both with `:TSInstall markdown markdown_inline` if needed.

The Jinja checkout supplies both `jinja` and `jinja_inline` for `.jinja`, `.jinja2`, and `.j2` templates. Retry both with `:TSInstall jinja jinja_inline` if needed.

For Go highlighting on Windows, clone the parsers you need from this list:

```cmd
git clone https://github.com/tree-sitter/tree-sitter-go.git "%USERPROFILE%\.local\parsers\go"
git -C "%USERPROFILE%\.local\parsers\go" checkout 2346a3ab1bb3857b48b29d779a1ef9799a248cd7
git clone https://github.com/camdencheek/tree-sitter-go-mod.git "%USERPROFILE%\.local\parsers\gomod"
git -C "%USERPROFILE%\.local\parsers\gomod" checkout 2e886870578eeba1927a2dc4bd2e2b3f598c5f9a
git clone https://github.com/tree-sitter-grammars/tree-sitter-go-sum.git "%USERPROFILE%\.local\parsers\gosum"
git -C "%USERPROFILE%\.local\parsers\gosum" checkout 27816eb6b7315746ae9fcf711e4e1396dc1cf237
git clone https://github.com/ngalaiko/tree-sitter-go-template.git "%USERPROFILE%\.local\parsers\gotmpl"
git -C "%USERPROFILE%\.local\parsers\gotmpl" checkout 06b2fd2ac32a7be71cdcf925eeeb868a68e2acde
git clone https://github.com/omertuc/tree-sitter-go-work.git "%USERPROFILE%\.local\parsers\gowork"
git -C "%USERPROFILE%\.local\parsers\gowork" checkout 949a8a470559543857a62102c84700d291fc984c
```

For config files, SQL, and web development, clone the parsers you need:

```cmd
git clone https://github.com/tree-sitter/tree-sitter-json.git "%USERPROFILE%\.local\parsers\json"
git -C "%USERPROFILE%\.local\parsers\json" checkout 254c42a6476413b776221e03982ac8ae159eeb72
git clone https://github.com/tree-sitter-grammars/tree-sitter-yaml.git "%USERPROFILE%\.local\parsers\yaml"
git -C "%USERPROFILE%\.local\parsers\yaml" checkout a1c4812a73ec5e089de8e441fdea3a921e8d5079
git clone https://github.com/tree-sitter-grammars/tree-sitter-toml.git "%USERPROFILE%\.local\parsers\toml"
git -C "%USERPROFILE%\.local\parsers\toml" checkout 64b56832c2cffe41758f28e05c756a3a98d16f41
git clone --branch gh-pages https://github.com/derekstride/tree-sitter-sql.git "%USERPROFILE%\.local\parsers\sql"
git -C "%USERPROFILE%\.local\parsers\sql" checkout e038788e5d4daba82dea35676bf49a216629e141
git clone https://github.com/tree-sitter/tree-sitter-javascript.git "%USERPROFILE%\.local\parsers\javascript"
git -C "%USERPROFILE%\.local\parsers\javascript" checkout 58404d8cf191d69f2674a8fd507bd5776f46cb11
git clone https://github.com/tree-sitter/tree-sitter-typescript.git "%USERPROFILE%\.local\parsers\typescript"
git -C "%USERPROFILE%\.local\parsers\typescript" checkout 75b3874edb2dc714fb1fd77a32013d0f8699989f
git clone https://github.com/tree-sitter/tree-sitter-css.git "%USERPROFILE%\.local\parsers\css"
git -C "%USERPROFILE%\.local\parsers\css" checkout dda5cfc5722c429eaba1c910ca32c2c0c5bb1a3f
```

The JavaScript parser covers `.jsx`, and the TypeScript checkout supplies both `typescript` and `tsx`.

Copy this repo's `nvim/init.lua` to `%LOCALAPPDATA%\nvim\init.lua`, preserving any laptop-specific edits. It automatically uses the local checkouts it finds on Windows. Restart Neovim with the portable build tools on `PATH` and, if needed, retry the affected parser with a command like `:TSInstall bash`.

### Review Git changes in Neovim

Use **Space h h** from a repository directory to open the Git status and diff panel, even before opening a file. The other shortcuts below require an open tracked file. Use them in Normal mode:

| Shortcut | Action |
| --- | --- |
| **Space h h** | Open the repository's changed-file list and inline diff panel. |
| **Space h f** | Force-refresh this repository's ahead/behind commit counts (no fetch). |
| **Space h d** | Compare unstaged changes side by side with the index. |
| **Space h D** | Compare all uncommitted changes in this file with `HEAD` (staged and unstaged). |
| **Space t i** | Toggle a full-file inline view against `HEAD` (staged and unstaged), with removed lines above their replacements. |
| **Space t d** | Toggle a whole-file side-by-side view against `HEAD` (staged and unstaged), with unchanged sections expanded. Press again in either pane to close it. |
| **Space h p** | Preview just the change under the cursor in a popup. |
| **Space h i** | Preview just the change under the cursor inline. |
| **go** | From the working-file pane, open an editing tab at the same line and column with the inline diff enabled. |
| **]c** / **[c** | Move to the next / previous change. |

Side-by-side diffs show the base on the left and your current file on the right. Similar lines are aligned, with changed blocks tinted. **Space h d / Space h D** compare the whole file but fold longer unchanged sections; press `zo` to expand a fold. **Space t d** opens the whole file without those folds and restores your folding preference when closed. It also replaces an active inline view. To return to inline, press **Space t d** to close its split, then **Space t i**. For a split opened with **Space h d / Space h D**, move to the left pane with **Ctrl+w h** and run `:close` first. Press **Space t i** again to close the inline view.

Changed lines use muted red for the old version and muted green for the new version, with darker red/green backgrounds over the changed words. Syntax colors remain and words are not made bold. In native side-by-side comparisons (**Space h d**, **Space h D**, **Space t d**, and **gu**), both shades stay red in the old pane and green in the current pane, including when the word-diff overlay is enabled. Temporary pane colors are removed when the comparison closes. This changes styling only; line matching and navigation stay the same.

Inline reviews (**Space h h**, **Space t i**, and **go**) use the configured diff matching, as side-by-side comparisons do. Isolated one- and two-line matched replacements appear as individual red old/new green pairs. Nearby replacements, additions, and deletions separated by **up to three unchanged lines** can form a chain; when the chain contains **three or more changed lines** and changes on both sides, its old content appears together above its new content. This also joins mixed pieces such as `1 old/1 new`, a deletion, and another replacement into one old section followed by one new section. Unchanged context is included in both versions with neutral text backgrounds; only actual edits receive red/green backgrounds and darker word highlights. Consecutive multi-line replacements and addition-only/deletion-only changes stay grouped. Gitsigns' built-in **]c** and **[c** follow these displayed pairs, blocks, or chains, including staged and unstaged changes against `HEAD`, and respect counts such as **2]c** and `wrapscan`. Normal editing keeps its usual unstaged-change navigation. Staging/reset actions retain Gitsigns' normal hunk selection rather than using the displayed chain; adjacent pieces can already belong to one normal Git hunk. **Space h i** remains the single-hunk inline preview. This display rule adds no Git commands or extra line-matching passes.

When the Git revision uses LF and the Windows working file uses CRLF, inline review compares the visible buffer text so line-ending differences do not color the entire file. This also handles the reverse format difference. File bytes, line-ending settings, and Git's staging comparison stay unchanged.

The **Space h h** review opens with two panes: the file list and an inline diff against `HEAD` showing staged and unstaged changes. Use **Ctrl+h / Ctrl+l** to move left/right, or **Ctrl+w**, then **w**, to cycle panes. For separate Neovim tabs, use **gt / gT** for next/previous. In the file list, **Enter** opens a file, **s / u** stage/unstage it, **gu** switches between inline and side-by-side layouts, **g?** shows help, and **q** closes the review. **]f / [f** move between changed files from the list or file panes.

Deleted lines wrap inside the inline views (**Space h h**, **Space t i**, **go**, and **Space h i**) when `wrap` is enabled. With `linebreak` enabled, wrapping prefers spaces; a word wider than the pane still splits. Highlights are preserved, the original line number appears only on the first row, and resizing reflows the preview. This custom adapter in `init.lua` works with Neovim 0.12 and the pinned Gitsigns version; it does not alter the file or the plugin checkout. Use `:setlocal nowrap` to restore horizontal scrolling.

To edit at the line you are reviewing, put the cursor on that line in the working-file pane and press **go**. The new tab starts with the inline diff against `HEAD` enabled (staged and unstaged changes); press **Space t i** if you want to hide it. The Git review stays open in its original tab; use **gT** to return or `:tabclose` to close the new editing tab. In the file list, **o** opens the selected file in a new tab; **go** is for preserving your cursor position in the file pane.

#### Troubleshoot side-by-side colors and alignment

In an affected **Space h d** or **Space h D** code pane:

1. If red and green highlights overlap within one line, put the cursor on an affected word and run this read-only check:

   ```vim
   :lua print('native='..vim.fn.synIDattr(vim.fn.diff_hlID('.',vim.fn.col('.')),'name')..' gitsigns_word_diff='..tostring(require('gitsigns.config').config.word_diff))
   ```

   `gitsigns_word_diff=true` means the additional Gitsigns word overlay is enabled; `false` means it is disabled. `native` identifies Neovim's diff highlight at the cursor. Use **`:messages`** if the output is cut off. The check prints highlight metadata without source text.

   Then try **`:Gitsigns toggle_word_diff false`**. This disables the extra Gitsigns word overlay while keeping native diff highlighting active. Check whether the mixture disappears before changing theme colors again, and keep the diagnostic output from before and after this command.
2. Run **`:set diffopt?`** and keep the output. The default `linematch:60` only aligns similar lines within change blocks containing at most 60 old and new lines combined. Larger blocks can pair shifted function definitions poorly.
3. Try a temporary, bounded increase:

   ```vim
   :set diffopt+=linematch:200
   :diffupdate
   ```

   Check the same function before and after this change. The larger limit can improve alignment, but matching may take longer on slower machines. It does not change the repository's configuration or file contents. Restart Neovim, or run **`:set diffopt+=linematch:60`** followed by **`:diffupdate`**, to restore the configured limit.

4. If the larger limit does not help, restore 60 and try a different alignment algorithm:

   ```vim
   :set diffopt+=linematch:60
   :set diffopt+=algorithm:patience
   :diffupdate
   ```

   Restore the configured algorithm with **`:set diffopt+=algorithm:histogram`** followed by **`:diffupdate`**. If both algorithms mismatch the same definitions, an anonymized before/after excerpt preserving indentation and blank lines is needed to reproduce that specific alignment choice.

The config sets `algorithm`, `linematch`, and `inline` individually so Neovim 0.12 replaces its defaults. Older config copies may show duplicate entries such as `linematch:40,linematch:60` and `inline:char,inline:word`.

When reporting a problem from another machine, include the highlight diagnostic and `diffopt` output, whether disabling the word overlay removed the mixed colors, and whether the temporary matching limit or algorithm improved the alignment. For alignment, identify which old function is directly opposite the new function, both line numbers, and which old definition should match instead. A deleted function paired with a different surviving function is an alignment problem; changing highlight colors does not correct that pairing. No source code is required for these initial checks.

#### Troubleshoot unexpected whole-file changes in the inline view

On the affected machine, open **Space h h**, select the affected file with **Enter**, and move the cursor into its code pane. Run this read-only command in Neovim:

```vim
:lua local v=require('gitsigns.unified').get_view(); local t={}; for i,h in ipairs(v and v.hunks or {}) do if i<=12 then t[#t+1]=h.type..':'..h.removed.count..'/'..h.added.count end end; local f=debug.getinfo(require('gitsigns.hunk_preview').capture_removed_hunks_from_source,'S'); print('renderer='..f.short_src..':'..f.linedefined); print('unified='..tostring(v~=nil)..' formats='..(v and (vim.bo[v.base].fileformat..'/'..vim.bo[v.buf].fileformat) or 'n/a')..' blocks='..table.concat(t,', '))
```

Use **`:messages`** to read or copy the output if it is cut off. It contains the renderer's source location, base/working-file line-ending formats, and the first 12 change blocks' types and line counts, without file contents.

| Output | Meaning |
| --- | --- |
| `renderer=...init.lua:...` | The custom inline display adapter is loaded. |
| `renderer=...gitsigns/hunk_preview.lua:...` | Gitsigns' original renderer is active. Check which config this Neovim instance loads with `:echo $MYVIMRC`. On Windows, copy the latest repo `nvim/init.lua` to `%LOCALAPPDATA%\nvim\init.lua`, then completely restart Neovim. |
| `unified=false` | The current pane is not a Gitsigns inline code view. Move out of the file list or switch back from side-by-side view with **gu** in the file list, then rerun the command. |
| `formats=unix/dos` | The Git revision uses LF and the working file uses CRLF. The adapter compares visible text to prevent a false whole-file replacement. `dos/unix` is handled the same way. |
| `change:1/1` | A single-line replacement, or one pair from a two-line matched replacement. |
| `change:80/80` | A grouped replacement or nearby-edit chain spanning 80 old and 80 new lines. Chain counts include neutral context. |
| `add:0/10` or `delete:10/0` | Ten added or deleted lines with no matched opposite side; these stay grouped. |

Inline reviews retain normal diff matching, with individual pairs for short isolated replacements and grouping for runs or chains containing three or more changed lines. Chain gaps may contain up to three unchanged lines, shown as neutral context. The earlier extra matching pass and its work budget have been removed. Larger displayed block counts can include chain context; investigate if unchanged text itself receives added/deleted backgrounds across an unexpectedly large part of the file.

Earlier versions of the adapter could show a whole-file replacement such as `change:923/1012` when the Git revision and working file had different LF/CRLF formats. Update the copied config and restart Neovim before interpreting a block of that size as a genuine large replacement.

### Read the statusline

The top bar shows the relative file path and unsaved (`[+]`) or read-only (`[RO]`) flags. Paths are not abbreviated by segment; paths wider than the pane are truncated to fit. The focused pane's path and bottom Git information follow the mode color: blue for Normal, green for Insert, purple for Visual, red for Replace, yellow for Command, and cyan for other modes. Backgrounds remain transparent and inactive panes stay muted. Error/warning counts keep their diagnostic colors.

The bottom statusline shows the Git branch once Gitsigns detects it, plus commit counts relative to its configured upstream: ` 2   1` means two commits ahead and one behind. Zero counts are shown; counts are omitted if Git cannot compare with an upstream (for example, a new branch without tracking configured). Checks run asynchronously and are cached per repository for two minutes on Windows and five seconds on macOS, measured from query completion. On Windows, entering a file, Git updates, focus, terminal, and shell events can refresh expired counts for files visible in the current tab; an idle cursor and hidden repositories do not launch queries. On macOS, idle checks remain enabled and focus, terminal, and shell events force a refresh. Press **Space h f** from an open tracked file to bypass the cache and refresh immediately. Counts use local tracking refs; run `git fetch` to learn about newer remote commits. The bar does not fetch automatically.

On Windows, **Space h h** returns to an existing review for that repository instead of opening another review and rereading Git. Saves and staging actions inside Neovim still refresh the file list. To rebuild the list after external Git changes, close the review with **q** and reopen it with **Space h h**. Gitsigns coalesces rapid edits for 500 ms (100 ms on macOS); repository watchers remain enabled so external staging and branch changes still update file signs. These settings reduce repeated work; opening a fresh review still needs to read repository status and file contents.

The active bottom statusline also shows the short mode (`N`, `I`, or `V`), error/warning counts (`E2 W1`), and line:column. Diagnostic counts appear in panes at least 80 columns wide. Zero diagnostic counts are hidden. Mode and position keep their mode colors, and inactive panes show muted Git information.

Git review panes use readable labels such as `Git changes`, `src/file.lua [HEAD]`, or `src/file.lua [Index]`; terminal panes show `Terminal`. Nerd Font support is enabled for both macOS and Windows; select your installed Nerd Font in the terminal's font settings. Setting `vim.g.have_nerd_font = false` restores plain-text fallbacks, including `ahead` and `behind` labels.

### Use terminals in Neovim

In Normal mode, press **Space t t** to open the Terminal submenu, then choose **t**, **s**, or **n**:

Which-key lists the main **Space** menu in the order **h, t, s, Space, /, q, f**, the **Space h** menu with **h** first and **f** second, the **Space t** menu in the order **i, t, b, m, w, h** (when those actions are available), and the Terminal submenu in the order **t, s, n**. Other entries retain their default sorting.

| Shortcut | Action |
| --- | --- |
| **Space t t t** | Open or hide the terminal panel, preserving running processes. |
| **Space t t s** | Select an existing terminal. |
| **Space t t n** | Create another terminal. |

Inside a terminal, press **Esc twice** to enter Normal mode before using these shortcuts. Press **Ctrl+k** to move to the editor above the terminal. Press **Ctrl+j**, then **i**, to return to the terminal and type commands. Run your project's usual commands there, such as `python main.py`, `npm run dev`, or `go run .`. Press **Ctrl+c** to stop a foreground program, or run `exit` to end the shell.

Terminals created with **Space t t t** or **Space t t n** read all variables from your project's `.vscode/settings.json`: `terminal.integrated.env.windows` on Windows, `.osx` on macOS, or `.linux` on Linux. Launch Neovim in the project directory (or use `:cd` there). Settings are found by searching upwards from `:pwd`, stopping at the Git root. There are no hardcoded variable names or values.

JSON comments and trailing commas are supported. Values can use `${workspaceFolder}`, `${workspaceFolderBasename}`, `${userHome}`, `${env:NAME}`, and `${pathSeparator}` (or `${/}`). A `null` value removes an inherited variable. Unsupported substitutions or invalid settings produce a warning and leave the terminal's environment inherited from Neovim.

After editing the settings, create a new terminal with **Space t t n**; hiding and reopening a terminal keeps its existing environment and processes. These settings apply only to terminals created through the shortcuts; Neovim's own environment, language servers, and terminals created directly with `:terminal`, `:ToggleTerm`, or `:TermNew` are unaffected. This terminal setup is contained in `nvim/init.lua`; copy it to `%LOCALAPPDATA%\nvim\init.lua` on Windows.

### Open Neovim by typing `vim`

Save the following as `vim.cmd` in a folder on your user `PATH`, such as `%USERPROFILE%\.local\bin`. Make sure `nvim` is also on `PATH`.

```cmd
@echo off
nvim %*
```

Try `vim README.md`. If it opens Vim, run `where vim` to see which executable comes first on `PATH`.
