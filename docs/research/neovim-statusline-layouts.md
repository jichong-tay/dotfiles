# Ready-made Neovim statusline layouts

Researched 2026-11-15 against primary documentation and example source. Selection criteria: existing mini.nvim/gitsigns, one `init.lua`, relative paths, short modes, blue Normal/green Insert, transparent vscode.nvim, and ordinary fonts on macOS/Windows.

## Practical starting point

**Choose lualine standard when the priority is an existing layout with simple component configuration.** It supplies Git/diagnostic components and allows setup in one Lua configuration. [Default configuration](https://github.com/nvim-lualine/lualine.nvim#default-configuration)

**For the least dependency change, adapt mini.statusline's official default-content recipe.** It already arranges mode, developer information, filename, file information, search count and cursor position; `setup()` uses it automatically. The maintainer explicitly recommends copying this function into `content.active` and tweaking it. This is an existing upstream layout, although it is not a gallery of named presets. [Default recipe](https://nvim-mini.org/mini.nvim/doc/mini-statusline.html#MiniStatusline-example-content), [maintainer guidance](https://github.com/nvim-mini/mini.nvim/discussions/1177)

For the mini route, keep its arrangement and change mode length, relative filename handling, icons and highlights. Mini supports `use_icons = false`, separate mode highlight groups, gitsigns fallback for branch/diff information, and native diagnostic counts. Its default filename section switches between `%F` and `%f`; always-relative paths need a deliberate adjustment. These are adaptations, not another ready-made preset. [Official source](https://github.com/nvim-mini/mini.nvim/blob/main/lua/mini/statusline.lua)

## Alternatives worth viewing

| Starting layout | What is actually ready | Fit here |
| --- | --- | --- |
| **Lualine standard** | `setup()` supplies mode; branch/diff/diagnostics; filename; encoding/format/type; progress/location. | Disable icons and empty both separator options for plain fonts. [Default configuration](https://github.com/nvim-lualine/lualine.nvim#default-configuration) |
| **Lualine slanted-gaps** | A complete upstream example, with branch/diff, separate error/warning components, relative filename, search and cursor information. | More configuration to retain: the example has 124 lines, a helper component and section-processing function. Its slants use private-use Powerline glyphs. [Example and source](https://github.com/nvim-lualine/lualine.nvim/blob/master/examples/slanted-gaps.lua) |
| **Lualine bubbles** | A complete upstream example with rounded mode/location ends, filename/branch, filetype and progress. | The example omits diagnostics/diff and supplies its own colors. Rounded ends use private-use Powerline glyphs; replacing them loses that particular appearance. [Example source](https://github.com/nvim-lualine/lualine.nvim/blob/master/examples/bubbles.lua) |

Lualine's [official gallery](https://github.com/nvim-lualine/lualine.nvim#screenshots) links these copy/adapt examples. They are **not** options such as `theme = 'bubbles'`: component layout (`sections`) and color theme (`options.theme`) are separate settings. [Configuration documentation](https://github.com/nvim-lualine/lualine.nvim#usage-and-customization)

Lualine documents `filename.path = 1` for relative paths and a mode `fmt` example returning the first letter. It also offers path shortening, so full relative paths require checking that setting. Blue/green mode colors and transparent backgrounds still need reviewing against the chosen theme. [Component options](https://github.com/nvim-lualine/lualine.nvim#component-options)

Heirline has a substantial [cookbook](https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md), but its own README says it provides no default statusline and requires writing one. I would not choose it for this request for an existing format. [Heirline README](https://github.com/rebelot/heirline.nvim#about)

Mini needs no additional plugin in this setup; lualine adds a dependency but offers explicit component tables and more visual examples. That is the relevant tradeoff here; this research does not establish a speed or long-term maintenance advantage for either.
