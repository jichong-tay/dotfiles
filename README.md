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

This config skips automatic Mason installs on Windows because Mason's ZIP installer calls PowerShell. Extract tools manually and put their executables on `PATH`, or transfer them from a matching Windows setup. Running `:MasonInstall` for a ZIP package still requires PowerShell.

```cmd
set "PATH=%USERPROFILE%\.local\w64devkit\bin;%USERPROFILE%\.local\bin;%PATH%"
where gcc make tree-sitter
nvim
```

If Tree-sitter picks the wrong compiler, run `set "CC=gcc"` in that CMD window before launching Neovim.

If you can't run the portable build tools, disable the `SECTION 9: TREESITTER` block and the `nvim-treesitter` build hook in the laptop's `init.lua`. Run `:checkhealth` after starting Neovim.

### Open Neovim by typing `vim`

Save the following as `vim.cmd` in a folder on your user `PATH`, such as `%USERPROFILE%\.local\bin`. Make sure `nvim` is also on `PATH`.

```cmd
@echo off
nvim %*
```

Try `vim README.md`. If it opens Vim, run `where vim` to see which executable comes first on `PATH`.
