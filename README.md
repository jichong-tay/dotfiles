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

Use Neovim 0.12 or newer and Git. Close Neovim, back up any existing `%LOCALAPPDATA%\nvim` folder, then use File Explorer to paste `init.lua`, `lua\`, and `nvim-pack-lock.json` directly into a new `%LOCALAPPDATA%\nvim` folder.

At startup, `vim.pack` can download the plugins from GitHub. For an offline laptop, copy the plugin folders from a Windows PC with the same Neovim version, CPU architecture, and lockfile into `%LOCALAPPDATA%\nvim-data\site\pack\core\opt`. Include each plugin's `.git` folder. For preinstalled tools or parsers, use Windows builds from that setup (`nvim-data\mason` and `nvim-data\site\parser`, with `site\queries` if present).

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

### Set up Lua Language Server without PowerShell

This config skips automatic Mason installs on Windows because Mason's ZIP installer calls PowerShell. Download the ZIP for your laptop's architecture from [Lua Language Server releases](https://github.com/LuaLS/lua-language-server/releases). Use **Extract All** in File Explorer to extract it to `%USERPROFILE%\.local\lua-language-server`. Keep the extracted files together.

In the same CMD window you use to launch Neovim, add the folder containing `lua-language-server.exe` to `PATH`:

```cmd
set "PATH=%USERPROFILE%\.local\lua-language-server\bin;%PATH%"
where lua-language-server
nvim "%LOCALAPPDATA%\nvim\init.lua"
```

If your ZIP extracted into an extra subfolder, adjust the `PATH` entry to match. In Neovim, run `:checkhealth vim.lsp` and look for `lua_ls` under active clients. Mason may still show it as uninstalled because you installed it manually.

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
```

The Markdown checkout supplies both `markdown` and `markdown_inline`. Retry both with `:TSInstall markdown markdown_inline` if needed.

Copy this repo's `nvim/init.lua` to `%LOCALAPPDATA%\nvim\init.lua`, preserving any laptop-specific edits. It automatically uses the local checkouts it finds on Windows. Restart Neovim with the portable build tools on `PATH` and, if needed, retry the affected parser with a command like `:TSInstall bash`.

### Open Neovim by typing `vim`

Save the following as `vim.cmd` in a folder on your user `PATH`, such as `%USERPROFILE%\.local\bin`. Make sure `nvim` is also on `PATH`.

```cmd
@echo off
nvim %*
```

Try `vim README.md`. If it opens Vim, run `where vim` to see which executable comes first on `PATH`.
