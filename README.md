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

### Open Neovim by typing `vim`

Save the following as `vim.cmd` in a folder on your user `PATH`, such as `%USERPROFILE%\.local\bin`. Make sure `nvim` is also on `PATH`.

```cmd
@echo off
nvim %*
```

Try `vim README.md`. If it opens Vim, run `where vim` to see which executable comes first on `PATH`.
