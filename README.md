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
