--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options
-- ============================================================
do
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()

  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Set to true if you have a Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = true

  -- [[ Setting options ]]
  --  See `:help vim.o`
  -- NOTE: You can change these options as you wish!
  --  For more options, you can see `:help option-list`

  -- Make line numbers default
  vim.o.number = true
  -- You can also add relative line numbers, to help with jumping.
  --  Experiment for yourself to see if you like it!
  vim.o.relativenumber = true

  -- Enable mouse mode, can be useful for resizing splits for example!
  vim.o.mouse = 'a'

  -- Don't show the mode, since it's already in the status line
  vim.o.showmode = false

  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- Enable break indent
  vim.o.breakindent = true
  -- Wrap at word boundaries instead of splitting words across display lines.
  vim.o.linebreak = true

  -- Enable undo/redo changes even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.o.signcolumn = 'yes'

  -- Decrease update time
  vim.o.updatetime = 250

  -- Decrease mapped sequence wait time
  vim.o.timeoutlen = 300

  -- Configure how new splits should be opened
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- Sets how neovim will display certain whitespace characters in the editor.
  --  See `:help 'list'`
  --  and `:help 'listchars'`
  --
  --  Notice listchars is set using `vim.opt` instead of `vim.o`.
  --  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
  --   See `:help lua-options`
  --   and `:help lua-guide-options`
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  -- Preview substitutions live, as you type!
  vim.o.inccommand = 'split'

  -- Show which line your cursor is on
  vim.o.cursorline = true

  -- Minimal number of screen lines to keep above and below the cursor.
  vim.o.scrolloff = 10

  -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
  -- instead raise a dialog asking if you wish to save the current file(s)
  -- See `:help 'confirm'`
  vim.o.confirm = true
end

-- Open files with the operating system's default application. Shared by the
-- keymaps and autocmds in Section 2 and the Telescope pickers in Section 5.
local function open_externally(path)
  local _, err = vim.ui.open(path)
  if err then vim.notify(err, vim.log.levels.ERROR) end
end

-- Select a file in Explorer or Finder; other systems open its folder.
local function reveal_externally(path)
  local cmd
  if vim.fn.has 'win32' == 1 then
    -- Explorer takes "/select," and the path as separate arguments.
    cmd = { 'explorer.exe', '/select,', (path:gsub('/', '\\')) }
  elseif vim.fn.has 'mac' == 1 then
    cmd = { 'open', '-R', path }
  else
    return open_externally(vim.fs.dirname(path))
  end
  local ok, err = pcall(vim.system, cmd, { detach = true })
  if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
end

-- The file on disk behind the current buffer; nil for terminals, Git views, etc.
local function current_file()
  local name = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= '' or name == '' or name:match '^%a[%w+.-]+://' then return nil end
  return vim.fn.fnamemodify(name, ':p')
end

-- ============================================================
-- SECTION 2: KEYMAPS & AUTOCMDS
-- basic keymaps, basic autocmds
-- ============================================================
do
  -- [[ Basic Keymaps ]]
  --  See `:help vim.keymap.set()`

  -- Clear highlights on search when pressing <Esc> in normal mode
  --  See `:help hlsearch`
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- Diagnostic Config & Keymaps
  --  See `:help vim.diagnostic.Opts`
  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- Tiny Inline Diagnostic displays and wraps messages beside the code.
    virtual_text = false,
    virtual_lines = false,

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
  -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
  -- is not what someone will guess without a bit more experience.
  --
  -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
  -- or just use <C-\><C-n> to exit terminal mode
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- TIP: Disable arrow keys in normal mode
  -- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
  -- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
  -- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
  -- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

  -- Keybinds to make split navigation easier.
  --  Use CTRL+<hjkl> to switch between windows
  --
  --  See `:help wincmd` for a list of all window commands
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  -- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
  -- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
  -- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
  -- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
  -- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

  -- [[ Basic Autocommands ]]
  --  See `:help lua-guide-autocommands`

  -- Highlight when yanking (copying) text
  --  Try it with `yap` in normal mode
  --  See `:help vim.hl.on_yank()`
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })

  -- [[ Open in other applications ]]
  local function with_current_file(action)
    return function()
      local path = current_file()
      if not path then
        vim.notify('This buffer is not a file on disk.', vim.log.levels.INFO)
        return
      end
      if vim.bo.modified then vim.notify('Using the saved file; this buffer has unsaved changes.', vim.log.levels.WARN) end
      action(path)
    end
  end
  vim.keymap.set('n', '<leader>o', with_current_file(open_externally), { desc = '[O]pen file in default app' })
  vim.keymap.set('n', '<leader>O', with_current_file(reveal_externally), { desc = '[O]pen file location in file manager' })

  -- Send documents, images and media to their default app instead of
  -- loading their bytes into a buffer. Use <leader>O to find the file itself.
  local external_types = {
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'xlsm', 'ppt', 'pptx',
    'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'ico',
    'mp3', 'wav', 'mp4', 'mov',
  }
  -- macOS and Windows already match patterns case-insensitively; adding both
  -- cases there would open each file twice.
  local external_patterns = {}
  for _, ext in ipairs(external_types) do
    external_patterns[#external_patterns + 1] = '*.' .. ext
    if not vim.o.fileignorecase then external_patterns[#external_patterns + 1] = '*.' .. ext:upper() end
  end
  vim.api.nvim_create_autocmd('BufReadCmd', {
    desc = 'Open binary documents with the default application',
    group = vim.api.nvim_create_augroup('dotfiles-open-externally', { clear = true }),
    pattern = external_patterns,
    callback = function(ev)
      -- Leave plugin buffers such as gitsigns://…/file.pdf to their own readers.
      if ev.match:match '^%a[%w+.-]+://' then return end
      open_externally(ev.match)
      local buf = ev.buf
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then return end
        -- Put each window back on the buffer it showed before.
        for _, win in ipairs(vim.fn.win_findbuf(buf)) do
          vim.api.nvim_win_call(win, function()
            local alt = vim.fn.bufnr '#'
            if alt > 0 and alt ~= buf and vim.api.nvim_buf_is_valid(alt) then vim.cmd.buffer(alt) else vim.cmd.enew() end
          end)
        end
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end)
    end,
  })
end

-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
local is_windows = vim.fn.has 'win32' == 1
local basic_treesitter_parsers = {
  'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
  'go', 'gomod', 'gosum', 'gotmpl', 'gowork', 'python', 'jinja', 'jinja_inline',
  'json', 'yaml', 'toml', 'sql', 'javascript', 'typescript', 'tsx', 'css',
}
local windows_parser_paths = {}
do
  -- The work laptop's curl fails Schannel revocation checks. Only install from local checkouts on Windows.
  if is_windows then
    local shared_checkouts = { jinja_inline = 'jinja', markdown_inline = 'markdown', tsx = 'typescript' }
    for _, name in ipairs(basic_treesitter_parsers) do
      local checkout = shared_checkouts[name] or name
      local path = vim.env.USERPROFILE .. '/.local/parsers/' .. checkout
      if vim.fn.isdirectory(path) == 1 then windows_parser_paths[name] = path end
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'TSUpdate',
      callback = function()
        local parsers = require 'nvim-treesitter.parsers'
        for name, path in pairs(windows_parser_paths) do
          parsers[name].install_info.path = path
        end
      end,
    })
  end

  -- [[ Intro to `vim.pack` ]]
  -- `vim.pack` is a new plugin manager built into Neovim,
  --  which provides a Lua interface for installing and managing plugins.
  --
  --  See `:help vim.pack`, `:help vim.pack-examples` or the
  --  excellent blog post from the creator of vim.pack and mini.nvim:
  --  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
  --
  --  To inspect plugin state and pending updates, run
  --    :lua vim.pack.update(nil, { offline = true })
  --
  --  To update plugins, run
  --    :lua vim.pack.update()
  --
  --
  --  Throughout the rest of the config there will be examples
  --  of how to install and configure plugins using `vim.pack`.
  --
  --  In this section we set up some autocommands to run build
  --  steps for certain plugins after they are installed or updated.

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- This autocommand runs after a plugin is installed or updated and
  --  runs the appropriate build command for that plugin if necessary.
  --
  -- See `:help vim.pack-events`
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' and not is_windows then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

--- Because most plugins are hosted on GitHub, you can use the helper
--- function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
  -- [[ Installing and Configuring Plugins ]]
  --
  -- To install a plugin simply call `vim.pack.add` with its git url.
  -- This will download the default branch of the plugin, which will usually be `main` or `master`
  -- You can also have more advanced specs, which we will talk about later.
  --
  -- For most plugins its not enough to install them, you also need to call their `.setup()` to start them.
  --
  -- For example, lets say we want to install `guess-indent.nvim` - a plugin for
  -- automatically detecting and setting the indentation.
  --
  -- We first install it from https://github.com/NMAC427/guess-indent.nvim
  -- and then call its `setup()` function to start it with default settings.
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  -- Here is a more advanced configuration example that passes options to `gitsigns.nvim`
  --
  -- See `:help gitsigns` to understand what each configuration key does.
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
  local gitsigns = require 'gitsigns'
  -- Neovim 0.12 cannot wrap virtual lines. Adapt Gitsigns' deleted-line
  -- renderer here so the plugin checkout and ordinary buffers stay untouched.
  do
    local deleted = require 'gitsigns.deleted_preview'
    local virt = require 'gitsigns.render.virt'
    local place = deleted.place_inline_preview_lines
    local wrapped_cache = setmetatable({}, { __mode = 'k' })
    local previews = {}

    local function wrap_deleted_line(chunks, text, source_gutter, gutter, width, tabstop, word_wrap, numbers)
      local prefix, tokens = {}, {}
      local prefix_width, source_bytes, source_column = 0, 0, 0
      for _, chunk in ipairs(chunks) do
        for _, char in ipairs(vim.fn.split(chunk[1], [[\zs]])) do
          if prefix_width < source_gutter then
            virt.add_chunk(prefix, char, chunk[2])
            prefix_width = prefix_width + vim.fn.strdisplaywidth(char)
          elseif source_bytes < #text then
            local cells = char == '\t' and (tabstop - source_column % tabstop) or vim.fn.strdisplaywidth(char)
            if char == '\t' then
              for _ = 1, cells do tokens[#tokens + 1] = { ' ', chunk[2], 1 } end
            else
              tokens[#tokens + 1] = { char, chunk[2], cells }
            end
            source_bytes, source_column = source_bytes + #char, source_column + cells
          else
            break -- Discard Gitsigns' synthetic end-of-line padding.
          end
        end
      end
      -- A retained single-hunk preview can outlive a gutter-width change.
      if source_gutter ~= gutter then
        local resized, skip = {}, math.max(source_gutter - gutter, 0)
        if numbers then
          for _, chunk in ipairs(prefix) do
            for _, char in ipairs(vim.fn.split(chunk[1], [[\zs]])) do
              if skip > 0 then skip = skip - vim.fn.strdisplaywidth(char)
              else virt.add_chunk(resized, char, chunk[2]) end
            end
          end
        end
        local padding = numbers and math.max(gutter - source_gutter, 0) or gutter
        table.insert(resized, 1, { string.rep(' ', padding), 'GitSignsVirtLnum' })
        prefix = resized
      end
      local rows, first = {}, 1
      local available = math.max(width - gutter, 1)
      repeat
        local last, cells, space = first - 1, 0, nil
        while last < #tokens and cells + tokens[last + 1][3] <= available do
          last = last + 1
          cells = cells + tokens[last][3]
          if tokens[last][1]:match '^%s+$' then space = last end
        end
        if word_wrap and last < #tokens and space then last = space end
        last = math.max(last, first) -- A single wide character may exceed a tiny pane.
        local row = #rows == 0 and vim.deepcopy(prefix) or { { string.rep(' ', gutter), 'GitSignsVirtLnum' } }
        cells = 0
        for i = first, math.min(last, #tokens) do
          virt.add_chunk(row, tokens[i][1], tokens[i][2])
          cells = cells + tokens[i][3]
        end
        -- Empty context lines inherit their original padding, not the red gutter.
        local tail = #tokens == 0 and chunks[#chunks] or row[#row]
        local eol_hl = tail and tail[2] or 'Normal'
        virt.add_chunk(row, string.rep(' ', math.max(available - cells, 0)), eol_hl)
        rows[#rows + 1], first = row, last + 1
      until first > #tokens
      return rows
    end

    local function reflow(preview)
      local win, buf = preview.win, preview.buf
      if not vim.api.nvim_win_is_valid(win) or not vim.api.nvim_buf_is_valid(buf)
        or vim.api.nvim_win_get_buf(win) ~= buf then return false end
      local mark = vim.api.nvim_buf_get_extmark_by_id(buf, preview.ns, preview.id, {})
      if #mark == 0 then return false end
      local info = vim.fn.getwininfo(win)[1]
      local width = vim.api.nvim_win_get_width(win) - (preview.leftcol and 0 or info.textoff)
      local gutter = preview.numbered and info.textoff or 0
      local tabstop, word_wrap = vim.bo[buf].tabstop, vim.wo[win].linebreak
      local numbers = vim.wo[win].number or vim.wo[win].relativenumber
      local key = table.concat({ win, width, gutter, tabstop, tostring(word_wrap), tostring(numbers), preview.start }, ':')
      local cached = preview.source and wrapped_cache[preview.source]
      local rows = preview.raw
      if vim.wo[win].wrap then
        if cached and cached.key == key then
          rows = cached.rows
        else
          rows = {}
          for i, chunks in ipairs(preview.raw) do
            vim.list_extend(rows, wrap_deleted_line(chunks, preview.texts[i] or '', preview.gutter, gutter, width, tabstop, word_wrap, numbers))
          end
          if preview.source then wrapped_cache[preview.source] = { key = key, rows = rows } end
        end
      end
      vim.api.nvim_buf_set_extmark(buf, preview.ns, mark[1], mark[2], {
        id = preview.id,
        virt_lines = rows,
        virt_lines_above = preview.above,
        virt_lines_leftcol = preview.leftcol,
        virt_lines_overflow = 'scroll',
      })
      return true
    end

    deleted.place_inline_preview_lines = function(buf, ns, hunk, staged, opts)
      local id = place(buf, ns, hunk, staged, opts)
      if not opts or not opts.win or not vim.api.nvim_win_is_valid(opts.win) then return id end
      local mark = vim.api.nvim_buf_get_extmark_by_id(buf, ns, id, { details = true })
      local texts = hunk.removed.lines
      if opts.lines then
        texts = {}
        for _, line in ipairs(opts.lines) do texts[#texts + 1] = line.text end
      end
      local preview = {
        win = opts.win, buf = buf, ns = ns, id = id, raw = mark[3].virt_lines,
        above = mark[3].virt_lines_above, leftcol = mark[3].virt_lines_leftcol,
        numbered = opts.lno_hl, texts = texts, source = opts.lines, start = hunk.removed.start,
        gutter = opts.lno_hl and vim.fn.getwininfo(opts.win)[1].textoff or 0,
      }
      reflow(preview)
      -- Unified views already redraw for each window. Single-hunk previews
      -- need an explicit reflow when their pane is resized or wrapping changes.
      if not opts.lines then previews[opts.win] = preview end
      return id
    end
    local group = vim.api.nvim_create_augroup('GitDeletedLineWrap', { clear = true })
    vim.api.nvim_create_autocmd('WinResized', {
      group = group,
      callback = function()
        for win, preview in pairs(previews) do
          if not reflow(preview) then previews[win] = nil end
        end
      end,
    })
    vim.api.nvim_create_autocmd('OptionSet', {
      group = group,
      pattern = { 'wrap', 'linebreak', 'tabstop', 'number', 'relativenumber', 'numberwidth', 'signcolumn' },
      callback = function()
        local win = vim.api.nvim_get_current_win()
        if previews[win] and not reflow(previews[win]) then previews[win] = nil end
      end,
    })
    vim.api.nvim_create_autocmd('WinClosed', {
      group = group,
      callback = function(ev) previews[tonumber(ev.match)] = nil end,
    })
  end
  -- Align similar lines in diff splits; the theme below controls their emphasis.
  -- Set keyed options separately: Lua :append() keeps duplicate defaults on Nvim 0.12.
  vim.cmd 'set diffopt+=algorithm:histogram'
  vim.cmd 'set diffopt+=linematch:60'
  vim.cmd 'set diffopt+=inline:word'
  gitsigns.setup {
    -- Coalesce rapid edits on slower Windows machines; keep Git watchers active
    -- so external staging and branch changes still update the comparison base.
    update_debounce = is_windows and 500 or 100,
    signs = {
      add = { text = '+' }, ---@diagnostic disable-line: missing-fields
      change = { text = '~' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
    },
    -- gitsigns.nvim's recommended keymaps:
    on_attach = function(bufnr)
      -- Navigation
      vim.keymap.set('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk 'next'
        end
      end, { desc = 'Jump to next git [c]hange', buf = bufnr })

      vim.keymap.set('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk 'prev'
        end
      end, { desc = 'Jump to previous git [c]hange', buf = bufnr })

      -- Visual mode actions
      vim.keymap.set('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [s]tage hunk', buf = bufnr })
      vim.keymap.set('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [r]eset hunk', buf = bufnr })
      -- Normal mode actions
      vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk', buf = bufnr })
      vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk', buf = bufnr })
      vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer', buf = bufnr })
      vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer', buf = bufnr })
      vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk', buf = bufnr })
      vim.keymap.set('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline', buf = bufnr })
      vim.keymap.set('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = 'git [b]lame line', buf = bufnr })
      vim.keymap.set('n', '<leader>hd', function() gitsigns.diffthis(nil, { vertical = true }) end, { desc = 'git [d]iff unstaged changes', buf = bufnr })
      vim.keymap.set('n', '<leader>hD', function() gitsigns.diffthis('HEAD', { vertical = true }) end, { desc = 'git [D]iff all uncommitted changes', buf = bufnr })
      vim.keymap.set('n', '<leader>hQ', function() gitsigns.setqflist 'all' end, { desc = 'git hunk [Q]uickfix list (all files in repo)', buf = bufnr })
      vim.keymap.set('n', '<leader>hq', gitsigns.setqflist, { desc = 'git hunk [q]uickfix list (all changes in this file)', buf = bufnr })
      -- Toggles
      vim.keymap.set('n', '<leader>ti', function() gitsigns.diffthis('HEAD', { unified = true }) end, { desc = '[T]oggle all uncommitted changes [i]nline', buf = bufnr })
      vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line', buf = bufnr })
      vim.keymap.set('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '[T]oggle git intra-line [w]ord diff', buf = bufnr })
      -- Text object
      vim.keymap.set({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'text object [i]nside [h]unk', buf = bufnr })
    end,
  }

  -- Whole-file split toggle: keep unchanged context expanded while reviewing.
  local full_splits = {}
  local function restore_full_split(state)
    if state.restored then return end
    state.restored = true
    for _, win in ipairs { state.source, state.base } do
      full_splits[win] = nil
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_call(win, function() vim.cmd 'diffoff' end)
        vim.wo[win].foldenable = state.foldenable
      end
    end
  end
  vim.keymap.set('n', '<leader>td', function()
    local win = vim.api.nvim_get_current_win()
    local state = full_splits[win]
    if state then
      if not state.base then return end -- A slow Git read is still opening it.
      if vim.api.nvim_win_is_valid(state.base) then vim.api.nvim_win_close(state.base, false) end
      restore_full_split(state)
      if vim.api.nvim_win_is_valid(state.source) then vim.api.nvim_set_current_win(state.source) end
      return
    end
    local existing = {}
    for _, other in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.wo[other].diff then
        vim.notify('Close the existing split comparison before using Space t d.', vim.log.levels.INFO)
        return
      end
      existing[other] = true
    end
    state = { source = win, tab = vim.api.nvim_get_current_tabpage(), foldenable = vim.wo.foldenable }
    full_splits[win] = state
    gitsigns.diffthis('HEAD', { vertical = true, unified = false }, function(err)
      if err or not vim.api.nvim_win_is_valid(win) then
        restore_full_split(state)
        if err then vim.notify(err, vim.log.levels.ERROR) end
        return
      end
      for _, other in ipairs(vim.api.nvim_tabpage_list_wins(state.tab)) do
        if not existing[other] and vim.wo[other].diff then state.base = other; break end
      end
      if not state.base then full_splits[win] = nil; return end
      full_splits[state.base] = state
      vim.wo[win].foldenable = false
      vim.wo[state.base].foldenable = false
      vim.api.nvim_create_autocmd('WinClosed', {
        pattern = { tostring(win), tostring(state.base) },
        once = true,
        callback = function() vim.schedule(function() restore_full_split(state) end) end,
      })
    end)
  end, { desc = '[T]oggle whole-file side-by-side [d]iff (HEAD)' })

  -- Native diff groups describe relative changes, not old/new sides. Give each
  -- pane a consistent tint, with a darker shade for its changed words.
  do
    local styled = {}
    local function tint(original, target)
      local mappings = {}
      local groups = { DiffAdd = true, DiffChange = true, DiffText = true, DiffTextAdd = true, DiffDelete = true }
      for _, name in ipairs { 'GitSignsAddLnInline', 'GitSignsChangeLnInline', 'GitSignsDeleteLnInline' } do groups[name] = true end
      for entry in original:gmatch '[^,]+' do
        if not groups[entry:match '^([^:]+):'] then mappings[#mappings + 1] = entry end
      end
      for name in pairs(groups) do
        local highlight = name == 'DiffDelete' and 'DotfilesDiffGap'
          or (name == 'DiffAdd' or name == 'DiffChange') and target
          or target .. 'Text'
        mappings[#mappings + 1] = name .. ':' .. highlight
      end
      table.sort(mappings)
      return table.concat(mappings, ',')
    end
    local function refresh()
      local targets = {}
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local wins = vim.tbl_filter(function(win) return vim.wo[win].diff end, vim.api.nvim_tabpage_list_wins(tab))
        if #wins == 2 then
          table.sort(wins, function(a, b)
            local pa, pb = vim.api.nvim_win_get_position(a), vim.api.nvim_win_get_position(b)
            return pa[2] == pb[2] and pa[1] < pb[1] or pa[2] < pb[2]
          end)
          local function revision(win) return vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)):match '^gitsigns://' ~= nil end
          if revision(wins[2]) and not revision(wins[1]) then wins[1], wins[2] = wins[2], wins[1] end
          targets[wins[1]], targets[wins[2]] = 'DotfilesDiffOld', 'DotfilesDiffNew'
        end
      end
      -- A split can inherit our temporary mappings from its parent window.
      local inherited = {}
      for _, state in pairs(styled) do inherited[state.applied] = state.original end
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local current, state = vim.wo[win].winhighlight, styled[win]
        if targets[win] then
          if not state or current ~= state.applied then state = { original = inherited[current] or current } end
          state.applied = tint(state.original, targets[win])
          if current ~= state.applied then vim.wo[win].winhighlight = state.applied end
          styled[win] = state
        else
          if state and current == state.applied then vim.wo[win].winhighlight = state.original
          elseif not state and inherited[current] then vim.wo[win].winhighlight = inherited[current] end
          styled[win] = nil
        end
      end
      for win in pairs(styled) do
        if not vim.api.nvim_win_is_valid(win) then styled[win] = nil end
      end
    end
    local pending = false
    local function schedule()
      if pending then return end
      pending = true
      vim.schedule(function()
        pending = false
        refresh()
      end)
    end
    local group = vim.api.nvim_create_augroup('dotfiles_diff_colors', { clear = true })
    vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter', 'WinResized', 'WinClosed', 'TabEnter' }, { group = group, callback = schedule })
    vim.api.nvim_create_autocmd('OptionSet', { group = group, pattern = 'diff', callback = schedule })
    schedule()
  end

  -- Match split diffs' 'diffopt' inline:word in Gitsigns' word highlights:
  -- darken whole changed words on both sides instead of single characters,
  -- and join changes split by a short non-word gap, using Nvim's rules
  -- (diff_refine_inline_word_highlight in src/nvim/diff.c).
  do
    local diff_int = require 'gitsigns.diff_int'
    local word_gap = 5

    -- Like Nvim's inline:word, join word characters (charclass 2, including
    -- accented letters); blanks, punctuation, CJK and emoji stand alone.
    local function split_words(line)
      local spans, col, word = {}, 1, false
      while col <= #line do
        local last = col + vim.str_utf_end(line, col)
        local is_word = vim.fn.charclass(line:sub(col, last)) == 2
        if is_word and word then spans[#spans][2] = last else spans[#spans + 1] = { col, last } end
        word, col = is_word, last + 1
      end
      return spans
    end

    local function has_word(text)
      for _, span in ipairs(split_words(text)) do
        if vim.fn.charclass(text:sub(span[1], span[2])) == 2 then return true end
      end
      return false
    end

    local function join_words(line, spans)
      local words = {}
      for i, span in ipairs(spans) do words[i] = line:sub(span[1], span[2]) .. '\n' end
      return table.concat(words)
    end

    -- Byte range [first, stop) covering words start .. start + count - 1.
    local function byte_range(spans, start, count)
      if count == 0 then
        local col = start == 0 and 1 or spans[start][2] + 1
        return col, col
      end
      return spans[start][1], spans[start + count - 1][2] + 1
    end

    diff_int.run_word_diff = function(removed, added)
      local rems, adds = {}, {}
      if #removed ~= #added then return rems, adds end
      local algorithm = require('gitsigns.config').config.diff_opts.algorithm
      for i = 1, #removed do
        local old, new = removed[i], added[i]
        local old_spans, new_spans = split_words(old), split_words(new)
        local regions = {}
        local parts = vim.text.diff(join_words(old, old_spans), join_words(new, new_spans),
          { result_type = 'indices', algorithm = algorithm, indent_heuristic = true })
        for _, part in ipairs(parts) do
          local os, oe = byte_range(old_spans, part[1], part[2])
          local ns, ne = byte_range(new_spans, part[3], part[4])
          local previous = regions[#regions]
          -- Unchanged text is identical on both sides, so test the old side.
          -- Join a 1-5 byte non-word gap when the changes are at least twice as long.
          local gap = previous and os - previous[2] or 0
          if gap > 0 and gap <= word_gap and not has_word(old:sub(previous[2], os - 1))
            and (oe - previous[1]) + (ne - previous[3]) - 2 * gap >= 2 * gap then
            previous[2], previous[4] = oe, ne
          else
            regions[#regions + 1] = { os, oe, ns, ne }
          end
        end
        for _, region in ipairs(regions) do
          local os, oe, ns, ne = unpack(region)
          local kind = os == oe and 'add' or ns == ne and 'delete' or 'change'
          rems[#rems + 1] = { i, kind, os, oe }
          adds[#adds + 1] = { i, kind, ns, ne }
        end
      end
      return rems, adds
    end
  end

  -- Show each change block as all removed lines, then all added lines, like
  -- VS Code. Linematch splits a block into adjacent line-pair hunks; rejoin
  -- them, and join across gaps of only a few unchanged characters (a blank
  -- line or a lone brace). Real context stays unchanged and separate, so ]c/[c,
  -- which read this list in the unified view, still stop at every change.
  -- Normalize LF/CRLF display comparisons without changing files or staging.
  do
    local unified = require 'gitsigns.unified'
    local hunks = require 'gitsigns.hunks'
    local preview = require 'gitsigns.hunk_preview'
    local capture = preview.capture_removed_hunks_from_source
    local highlight_added = preview.highlight_added_hunk
    local trivial_gap_chars = 4 -- VS Code's removeVeryShortMatchingLinesBetweenDiffs limits
    local trivial_gap_min_block = 5
    local blocks = setmetatable({}, { __mode = 'k' })

    -- Empty diff nodes point after the previous line; nonempty nodes start on
    -- a one-based line. Compare both as zero-based boundaries.
    local function start_row(node) return node.start - (node.count > 0 and 1 or 0) end

    -- Members keep their own word diffs; joined gap lines get the line color.
    preview.highlight_added_hunk = function(buf, ns, hunk)
      local members = blocks[hunk]
      if not members then return highlight_added(buf, ns, hunk) end
      for row = hunk.added.start - 1, hunk.added.start + hunk.added.count - 2 do
        vim.api.nvim_buf_set_extmark(buf, ns, row, 0, { end_row = row + 1, hl_group = 'GitSignsAddPreview', hl_eol = true, priority = 1000 })
      end
      for _, member in ipairs(members) do highlight_added(buf, ns, member) end
    end

    preview.capture_removed_hunks_from_source = function(buf, base, display_hunks, opts)
      local inline = unified.is_active(buf, base) and opts.line_hl == 'GitSignsDeleteVirtLn'
      if inline
        and vim.bo[buf].fileformat ~= vim.bo[base].fileformat
        and (vim.bo[buf].fileformat == 'dos' or vim.bo[base].fileformat == 'dos') then
        local config = require('gitsigns.config').config.diff_opts
        local display_opts = { result_type = 'indices', linematch = type(config.linematch) == 'number' and config.linematch or false }
        for _, key in ipairs({ 'algorithm', 'indent_heuristic', 'ignore_whitespace', 'ignore_whitespace_change', 'ignore_whitespace_change_at_eol', 'ignore_blank_lines', 'ignore_cr_at_eol' }) do
          display_opts[key] = config[key]
        end
        -- Gitsigns' raw comparison restores CRs for DOS buffers. Match the
        -- visible text, as native vimdiff does, when Git's LF base differs.
        local old_lines = vim.api.nvim_buf_get_lines(base, 0, -1, false)
        local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        if vim.bo[base].endofline then old_lines[#old_lines + 1] = '' end
        if vim.bo[buf].endofline then new_lines[#new_lines + 1] = '' end
        local raw = vim.text.diff(table.concat(old_lines, '\n'), table.concat(new_lines, '\n'), display_opts)
        -- Only replace the view's hunks; stage/reset keeps the original cache.
        for i = #display_hunks, 1, -1 do display_hunks[i] = nil end
        for _, part in ipairs(raw) do
          local section = hunks.create_hunk(part[1], part[2], part[3], part[4])
          for _, side in ipairs({ 'removed', 'added' }) do
            local node = section[side]
            local lines = side == 'removed' and old_lines or new_lines
            if node.count > 0 then
              node.lines = vim.list_slice(lines, node.start, node.start + node.count - 1)
              node.no_nl_at_eof = node.start + node.count > #lines and lines[#lines] ~= '' or nil
            end
          end
          display_hunks[#display_hunks + 1] = section
        end
      end
      if inline then
        local sections = {}
        local function joinable(last, next_hunk, size)
          local gap = start_row(next_hunk.removed) - start_row(last.removed) - last.removed.count
          if gap < 0 then return false end
          if gap == 0 then return true end
          local next_size = next_hunk.removed.count + next_hunk.added.count
          if size <= trivial_gap_min_block and next_size <= trivial_gap_min_block then return false end
          local first = start_row(last.removed) + last.removed.count
          local text = table.concat(vim.api.nvim_buf_get_lines(base, first, first + gap, false)):gsub('%s', '')
          return #text <= trivial_gap_chars
        end
        local i = 1
        while i <= #display_hunks do
          local first, last, stop = display_hunks[i], display_hunks[i], i
          local size = first.removed.count + first.added.count
          local removed, added = first.removed.count, first.added.count
          while stop < #display_hunks and joinable(last, display_hunks[stop + 1], size) do
            stop, last = stop + 1, display_hunks[stop + 1]
            size = size + last.removed.count + last.added.count
            removed, added = removed + last.removed.count, added + last.added.count
          end
          -- Joining pure additions would only paint unchanged gap lines red.
          if stop > i and removed > 0 and added > 0 then
            local old_start, new_start = start_row(first.removed), start_row(first.added)
            local merged = hunks.create_hunk(old_start + 1, start_row(last.removed) + last.removed.count - old_start,
              new_start + 1, start_row(last.added) + last.added.count - new_start)
            for _, side in ipairs({ 'removed', 'added' }) do
              local node = merged[side]
              local source = side == 'removed' and base or buf
              local last_line = node.start + node.count - 1
              node.lines = vim.api.nvim_buf_get_lines(source, node.start - 1, last_line, false)
              node.no_nl_at_eof = last_line == vim.api.nvim_buf_line_count(source) and not vim.bo[source].endofline or nil
            end
            blocks[merged] = vim.list_slice(display_hunks, i, stop)
            sections[#sections + 1] = merged
          else
            vim.list_extend(sections, display_hunks, i, stop)
          end
          i = stop + 1
        end
        for index = #display_hunks, 1, -1 do display_hunks[index] = nil end
        vim.list_extend(display_hunks, sections)
        local captured = {}
        for index, hunk in ipairs(display_hunks) do
          local members = blocks[hunk]
          if members then
            -- Color the whole block, then restore each member's word diff.
            local rows = capture(buf, base, { hunk }, { line_hl = opts.line_hl, word_diff = false })[1]
            local edits = capture(buf, base, members, opts)
            for member_index, member in ipairs(members) do
              for offset, line in ipairs(edits[member_index]) do rows[member.removed.start - hunk.removed.start + offset] = line end
            end
            captured[index] = rows
          else
            captured[index] = capture(buf, base, { hunk }, opts)[1]
          end
        end
        return captured
      end
      return capture(buf, base, display_hunks, opts)
    end
  end

  -- Reuse each Windows repository review instead of rereading Git on every hh.
  -- Closing it with q and reopening still requests a fresh review.
  local git_reviews, opening_reviews = {}, {}
  vim.keymap.set('n', '<leader>hh', function()
    if not is_windows then
      gitsigns.diff(nil, nil, { diff = 'unified' })
      return
    end
    local file = vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) or ''
    local root = (vim.b.gitsigns_status_dict or {}).root or (file ~= '' and vim.fs.root(file, '.git'))
    if not root then
      for path, review in pairs(git_reviews) do
        if review.tab == vim.api.nvim_get_current_tabpage() then root = path; break end
      end
    end
    root = root or vim.fs.root(vim.fn.getcwd(), '.git')
    if not root then
      gitsigns.diff(nil, nil, { diff = 'unified' })
      return
    end
    root = vim.fs.normalize(vim.uv.fs_realpath(root) or root):lower()
    local review = git_reviews[root]
    if review and vim.api.nvim_win_is_valid(review.win) and vim.api.nvim_win_get_buf(review.win) == review.buf then
      vim.api.nvim_set_current_win(review.win)
      return
    end
    if opening_reviews[root] then return end
    git_reviews[root], opening_reviews[root] = nil, true
    gitsigns.diff(nil, nil, { diff = 'unified' }, function(err)
      opening_reviews[root] = nil
      if err then vim.notify(err, vim.log.levels.ERROR); return end
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_name(buf):match '^gitsigns%-diff://' then
          git_reviews[root] = { tab = vim.api.nvim_get_current_tabpage(), win = win, buf = buf }
          break
        end
      end
    end)
  end, { desc = 'git status and inline diff panel' })
  vim.keymap.set('n', 'go', function()
    if vim.bo.buftype ~= '' or vim.api.nvim_buf_get_name(0) == '' then
      vim.notify('Move to the working file pane before opening it in a new tab.', vim.log.levels.INFO)
      return
    end
    vim.cmd 'tab split'
    vim.cmd 'diffoff'
    gitsigns.diffthis('HEAD', { unified = true })
  end, { desc = 'Open current file at cursor with inline diff' })

  vim.pack.add { gh 'akinsho/toggleterm.nvim' }
  require('toggleterm').setup { direction = 'horizontal' }
  -- Read project terminal settings without changing Neovim's own environment.
  local function terminal_environment(dir)
    local inherited = vim.fn.environ()
    local root = dir
    local path
    while root do
      local candidate = vim.fs.joinpath(root, '.vscode', 'settings.json')
      if vim.fn.filereadable(candidate) == 1 then
        path = candidate
        break
      end
      if vim.uv.fs_stat(vim.fs.joinpath(root, '.git')) then break end
      local parent = vim.fs.dirname(root)
      root = parent ~= root and parent or nil
    end
    if not path then return inherited end

    local ok, environment = pcall(function()
      local json = table.concat(vim.fn.readfile(path), '\n')
      local settings = vim.json.decode(require('plenary.json').json_strip_comments(json))
      local windows = vim.fn.has 'win32' == 1
      local platform = windows and 'windows' or (vim.fn.has 'macunix' == 1 and 'osx' or 'linux')
      local overrides = settings['terminal.integrated.env.' .. platform]
      if overrides == nil then return inherited end
      assert(type(overrides) == 'table', 'terminal environment must be an object')
      local env = vim.deepcopy(inherited)
      for name, value in pairs(overrides) do
        assert(type(name) == 'string' and name ~= '' and not name:find '[=%z]', 'invalid environment variable name')
        assert(value == vim.NIL or type(value) == 'string', 'environment values must be strings or null')
        if windows then
          -- Windows treats Path and PATH as the same variable.
          for key in pairs(env) do
            if key:upper() == name:upper() then env[key] = nil end
          end
        end
        if value == vim.NIL then
          env[name] = nil
        else
          env[name] = value:gsub('%${([^}]+)}', function(variable)
            if variable == 'workspaceFolder' then return root end
            if variable == 'workspaceFolderBasename' then return vim.fs.basename(root) end
            if variable == 'userHome' then return vim.fn.expand '~' end
            if variable == 'pathSeparator' or variable == '/' then return windows and '\\' or '/' end
            if variable:sub(1, 4) == 'env:' then return vim.env[variable:sub(5)] or '' end
            error('unsupported substitution: ${' .. variable .. '}')
          end)
          assert(not env[name]:find '%z', 'environment values cannot contain NUL')
        end
      end
      return env
    end)
    if ok then return environment end
    vim.notify('Cannot load terminal environment from ' .. path .. '; using inherited environment. Check its JSON and substitutions.', vim.log.levels.WARN)
    return inherited
  end

  local function new_terminal()
    local dir = vim.fn.getcwd()
    require('toggleterm.terminal').Terminal:new {
      dir = dir,
      env = terminal_environment(dir),
      clear_env = true, -- Preserve inherited variables except those explicitly set to null.
    }:toggle()
  end

  local function toggle_terminal()
    if #require('toggleterm.terminal').get_all() == 0 then
      new_terminal()
    else
      require('toggleterm').toggle()
    end
  end

  vim.keymap.set('n', '<leader>ttt', toggle_terminal, { desc = '[T]oggle terminal' })
  vim.keymap.set('n', '<leader>ttn', new_terminal, { desc = '[N]ew terminal' })
  vim.keymap.set('n', '<leader>tts', '<cmd>TermSelect<CR>', { desc = '[S]elect terminal' })

  -- Useful plugin to show you pending keybinds.
  vim.pack.add { gh 'folke/which-key.nvim' }
  local leader_order = { h = 1, t = 2, s = 3, ['<Space>'] = 4, ['/'] = 5, q = 6, f = 7 }
  local git_order = { h = 1, f = 2 }
  local toggle_order = { i = 1, d = 2, t = 3, b = 4, m = 5, w = 6, h = 7 }
  local terminal_order = { t = 1, s = 2, n = 3 }
  local leader_prefix = vim.fn.keytrans(vim.g.mapleader)
  require('which-key').setup {
    -- Delay between pressing a key and opening which-key (milliseconds)
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    sort = {
      function(item)
        local parent = item.node.parent and item.node.parent.keys
        local order
        if parent == leader_prefix then
          order = leader_order
        elseif parent == leader_prefix .. 'h' then
          order = git_order
        elseif parent == leader_prefix .. 't' then
          order = toggle_order
        elseif parent == leader_prefix .. 'tt' then
          order = terminal_order
        end
        return order and (order[item.node.key] or 1000) or 1000
      end,
      'local', 'order', 'group', 'alphanum', 'mod',
    },
    -- Document existing key chains
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>tt', group = '[T]erminal' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
    },
  }

  -- [[ Colorscheme ]]
  -- Use a VS Code-inspired dark palette.
  vim.pack.add { gh 'Mofiqul/vscode.nvim' }
  vim.o.background = 'dark'
  require('vscode').setup {
    transparent = true,
    terminal_colors = false,
    group_overrides = {
      NormalFloat = { bg = 'NONE' },
      FloatBorder = { bg = 'NONE' },
      Pmenu = { bg = 'NONE' },
      PmenuSbar = { bg = 'NONE' },
      TabLine = { fg = '#94a3b8', bg = 'NONE' },
      TabLineSel = { fg = '#0f172a', bg = '#93c5fd', bold = true },
      TabLineFill = { bg = 'NONE' },
      WinBar = { fg = '#93c5fd', bg = 'NONE', bold = true },
      WinBarNC = { fg = '#94a3b8', bg = 'NONE' },
      -- Muted line backgrounds and darker changed words preserve syntax colors.
      DotfilesDiffOld = { bg = '#322027' },
      DotfilesDiffNew = { bg = '#1d3025' },
      DotfilesDiffOldText = { bg = '#241016' },
      DotfilesDiffNewText = { bg = '#102318' },
      DotfilesDiffGap = { fg = '#718096', bg = 'NONE' },
      DiffAdd = { link = 'DotfilesDiffNew' },
      DiffDelete = { link = 'DotfilesDiffGap' },
      DiffChange = { bg = '#272b32' },
      DiffText = { bg = '#1c1f25' },
      DiffTextAdd = { link = 'DotfilesDiffNewText' },
      GitSignsAddPreview = { link = 'DotfilesDiffNew' },
      GitSignsDeletePreview = { link = 'DotfilesDiffOld' },
      GitSignsDeleteVirtLn = { link = 'DotfilesDiffOld' },
      GitSignsAddInline = { link = 'DotfilesDiffNewText' },
      GitSignsChangeInline = { link = 'DotfilesDiffNewText' },
      GitSignsDeleteInline = { link = 'DotfilesDiffOldText' },
      GitSignsDeleteVirtLnInLine = { link = 'DotfilesDiffOldText' },
      StatusLine = { bg = 'NONE' },
      StatusLineNC = { bg = 'NONE' },
      MiniStatuslineFilename = { fg = '#d4d4d4', bg = 'NONE' },
      MiniStatuslineDevinfo = { fg = '#93c5fd', bg = 'NONE' },
      MiniStatuslineInactive = { fg = '#94a3b8', bg = 'NONE' },
      MiniStatuslineModeNormal = { fg = '#0f172a', bg = '#93c5fd', bold = true },
      MiniStatuslineModeInsert = { fg = '#0f172a', bg = '#86efac', bold = true },
      MiniStatuslineModeVisual = { fg = '#0f172a', bg = '#c4b5fd', bold = true },
      MiniStatuslineModeReplace = { fg = '#0f172a', bg = '#fca5a5', bold = true },
      MiniStatuslineModeCommand = { fg = '#0f172a', bg = '#fde68a', bold = true },
      MiniStatuslineModeOther = { fg = '#0f172a', bg = '#a5f3fc', bold = true },
    },
  }
  vim.cmd.colorscheme 'vscode'

  vim.pack.add { gh 'rachartier/tiny-inline-diagnostic.nvim' }
  require('tiny-inline-diagnostic').setup {
    preset = vim.g.have_nerd_font and 'modern' or 'nonerdfont',
    transparent_bg = true,
    options = {
      multilines = { enabled = true },
      overflow = { mode = 'wrap' },
    },
  }

  -- Highlight todo, notes, etc in comments
  vim.pack.add { gh 'folke/todo-comments.nvim' }
  require('todo-comments').setup { signs = false }

  -- [[ mini.nvim ]]
  --  A collection of various small independent plugins/modules
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  -- If a nerd font is available, load the icons module for pretty icons in various plugins.
  if vim.g.have_nerd_font then
    require('mini.icons').setup()
    -- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
    MiniIcons.mock_nvim_web_devicons()
  end

  -- Better Around/Inside textobjects
  --
  -- Examples:
  --  - va)  - [V]isually select [A]round [)]paren
  --  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
  --  - ci'  - [C]hange [I]nside [']quote
  require('mini.ai').setup {
    -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  -- Add/delete/replace surroundings (brackets, quotes, etc.)
  --
  -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
  -- - sd'   - [S]urround [D]elete [']quotes
  -- - sr)'  - [S]urround [R]eplace [)] [']
  require('mini.surround').setup()

  -- Keep relative paths readable, including in Git review and terminal panes.
  local statusline = require 'mini.statusline'
  -- Cache upstream commit counts; never run Git while drawing the bars.
  local branch_counts = {}
  local branch_counts_cache_ms = is_windows and 120000 or 5000
  local function refresh_branch_counts(buf, force)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local status = vim.b[buf].gitsigns_status_dict or {}
    local root, head = status.root, status.head
    if not root or not head then
      vim.b[buf].git_ahead_behind = ''
      return
    end
    local cached = branch_counts[root]
    vim.b[buf].git_ahead_behind = cached and cached.head == head and cached.text or ''
    -- Hidden buffers can emit GitSignsUpdate; do not launch background queries
    -- for repositories outside the current tab on Windows.
    if is_windows and not force and vim.fn.bufwinid(buf) == -1 then return end
    local now = vim.uv.now()
    if cached and cached.head == head then
      if cached.running then
        cached.refresh = cached.refresh or force
        return
      end
      if not force and now - cached.time < branch_counts_cache_ms then return end
    end
    local entry = { head = head, text = vim.b[buf].git_ahead_behind, time = now, running = true }
    branch_counts[root] = entry
    local function on_result(result)
      vim.schedule(function()
        if branch_counts[root] ~= entry then return end
        local ahead, behind
        if result.code == 0 then ahead, behind = (result.stdout or ''):match('^(%d+)%s+(%d+)') end
        local ahead_label = vim.g.have_nerd_font and '' or 'ahead'
        local behind_label = vim.g.have_nerd_font and '' or 'behind'
        entry.text = ahead and ('%s %s  %s %s'):format(ahead_label, ahead, behind_label, behind) or ''
        entry.running = false
        entry.time = vim.uv.now()
        local refresh_buf
        for _, other in ipairs(vim.api.nvim_list_bufs()) do
          local other_status = vim.b[other].gitsigns_status_dict or {}
          if other_status.root == root and other_status.head == head then
            vim.b[other].git_ahead_behind = entry.text
            refresh_buf = other
          end
        end
        vim.cmd 'redrawstatus!'
        if entry.refresh and refresh_buf then refresh_branch_counts(refresh_buf, true) end
      end)
    end
    local ok = pcall(vim.system, { 'git', 'rev-list', '--left-right', '--count', 'HEAD...@{upstream}' }, { cwd = root, text = true, timeout = 5000 }, on_result)
    if not ok then on_result { code = -1 } end
  end
  vim.keymap.set('n', '<leader>hf', function()
    if not (vim.b.gitsigns_status_dict or {}).root then
      vim.notify('Open a tracked file in the repository to refresh its commit counts.', vim.log.levels.INFO)
      return
    end
    refresh_branch_counts(vim.api.nvim_get_current_buf(), true)
  end, { desc = 'git [f]orce ahead/behind refresh' })
  local branch_group = vim.api.nvim_create_augroup('GitBranchWinbar', { clear = true })
  vim.api.nvim_create_autocmd('User', {
    group = branch_group,
    pattern = 'GitSignsUpdate',
    callback = function(ev) refresh_branch_counts(ev.data and ev.data.buffer or vim.api.nvim_get_current_buf()) end,
  })
  vim.api.nvim_create_autocmd(is_windows and { 'BufEnter' } or { 'BufEnter', 'CursorHold' }, {
    group = branch_group,
    callback = function(ev) refresh_branch_counts(ev.buf) end,
  })
  vim.api.nvim_create_autocmd({ 'FocusGained', 'TermLeave', 'TermClose', 'ShellCmdPost' }, {
    group = branch_group,
    callback = function()
      local seen = {}
      local buffers = is_windows and vim.tbl_map(vim.api.nvim_win_get_buf, vim.api.nvim_tabpage_list_wins(0)) or vim.api.nvim_list_bufs()
      for _, buf in ipairs(buffers) do
        local root = (vim.b[buf].gitsigns_status_dict or {}).root
        if root and not seen[root] then
          seen[root] = true
          -- Windows process launches can be slow; only manual refresh bypasses its cache.
          refresh_branch_counts(buf, not is_windows)
        end
      end
    end,
  })
  -- Name a buffer as a relative path plus suffix; special buffers have no path.
  local function buffer_label(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match '^gitsigns%-diff://' then return 'Git changes', '', false end
    if vim.bo[buf].buftype == 'terminal' then return 'Terminal', '', false end
    local revision, path = name:match '^gitsigns://.-//(.-):(.*)$'
    if revision then
      if revision == '' and path:sub(1, 2) == '0:' then revision, path = 'Index', path:sub(3) end
      return path, ' [' .. revision .. ']', true
    end
    if name == '' then return '[No Name]', '', false end
    return vim.fn.fnamemodify(name, ':.'), '', true
  end
  local function statusline_filename()
    local path, suffix = buffer_label(0)
    return (path .. suffix):gsub('%%', '%%%%') .. '%m%r'
  end
  -- Winbar expressions need a globally callable function; keep its code here.
  _G.DotfilesWinbar = statusline_filename
  vim.o.winbar = '%<%{%v:lua.DotfilesWinbar()%}'

  -- Tabs show only each tab's current file name; the bars keep the full path.
  _G.DotfilesTabline = function()
    local parts, current = {}, vim.api.nvim_get_current_tabpage()
    for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
      local buf = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab))
      local label, suffix, is_path = buffer_label(buf)
      if is_path then
        local tail = vim.fn.fnamemodify(label, ':t')
        if tail ~= '' then label = tail end
      end
      label = (label .. suffix):gsub('%%', '%%%%')
      if vim.bo[buf].modified then label = label .. ' +' end
      parts[#parts + 1] = ('%%#%s#%%%dT %s '):format(tab == current and 'TabLineSel' or 'TabLine', index, label)
    end
    return table.concat(parts) .. '%#TabLineFill#%T'
  end
  vim.o.tabline = '%!v:lua.DotfilesTabline()'

  statusline.setup {
    use_icons = vim.g.have_nerd_font,
    content = {
      active = function()
        local mode, mode_hl = statusline.section_mode { trunc_width = math.huge }
        local git = statusline.section_git { trunc_width = 0 }
        local counts = {}
        if not statusline.is_truncated(80) and vim.diagnostic.is_enabled { bufnr = 0 } then counts = vim.diagnostic.count(0) end
        local errors = counts[vim.diagnostic.severity.ERROR] or 0
        local warnings = counts[vim.diagnostic.severity.WARN] or 0
        return statusline.combine_groups {
          { hl = mode_hl, strings = { mode } },
          '%<',
          { hl = 'MiniStatuslineFilename', strings = { statusline_filename() } },
          { hl = 'MiniStatuslineDevinfo', strings = { (git:gsub('%%', '%%%%')) } },
          '%=',
          { hl = 'MiniStatuslineDevinfo', strings = { '%{get(b:, "git_ahead_behind", "")}' } },
          { hl = 'DiagnosticError', strings = { errors > 0 and ('E' .. errors) or '' } },
          { hl = 'DiagnosticWarn', strings = { warnings > 0 and ('W' .. warnings) or '' } },
          { hl = mode_hl, strings = { '%l:%v' } },
        }
      end,
      inactive = function()
        return statusline.combine_groups {
          { hl = 'MiniStatuslineInactive', strings = { statusline_filename(), (statusline.section_git { trunc_width = 0 }:gsub('%%', '%%%%')), '%{get(b:, "git_ahead_behind", "")}' } },
        }
      end,
    },
  }

  -- Match the active filepath and Git accents to the existing mode badges.
  local function sync_bar_colors()
    local _, mode_hl = statusline.section_mode { trunc_width = math.huge }
    local mode_colors = vim.api.nvim_get_hl(0, { name = mode_hl, link = false })
    local accent = mode_colors.bg or '#93c5fd'
    vim.api.nvim_set_hl(0, 'WinBar', { fg = accent, bg = 'NONE', bold = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineDevinfo', { fg = accent, bg = 'NONE' })
    vim.cmd 'redrawstatus!'
  end
  vim.api.nvim_create_autocmd({ 'ModeChanged', 'ColorScheme' }, {
    group = vim.api.nvim_create_augroup('ModeBarColors', { clear = true }),
    callback = sync_bar_colors,
  })
  sync_bar_colors()
end

-- ============================================================
-- SECTION 5: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
  -- [[ Fuzzy Finder (files, lsp, etc) ]]
  --
  -- Telescope is a fuzzy finder that comes with a lot of different things that
  -- it can fuzzy find! It's more than just a "file finder", it can search
  -- many different aspects of Neovim, your workspace, LSP, and more!
  --
  -- There are lots of other alternative pickers (like snacks.picker, or fzf-lua)
  -- so feel free to experiment and see what you like!
  --
  -- The easiest way to use Telescope, is to start by doing something like:
  --  :Telescope help_tags
  --
  -- After running this command, a window will open up and you're able to
  -- type in the prompt window. You'll see a list of `help_tags` options and
  -- a corresponding preview of the help.
  --
  -- Two important keymaps to use while in Telescope are:
  --  - Insert mode: <c-/>
  --  - Normal mode: ?
  --
  -- This opens a window that shows you all of the keymaps for the current
  -- Telescope picker. This is really useful to discover what Telescope can
  -- do as well as how to actually do it!

  ---@type (string | vim.pack.Spec)[]
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
  }
  if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

  -- NOTE: You can install multiple plugins at once
  vim.pack.add(telescope_plugins)

  -- See `:help telescope` and `:help telescope.setup()`
  -- <C-o> opens the selected files (or all multi-selected with <Tab>) in their
  -- default applications, e.g. spreadsheets from <leader>sf.
  local function open_selection_externally(prompt_bufnr)
    local action_state = require 'telescope.actions.state'
    local entries = action_state.get_current_picker(prompt_bufnr):get_multi_selection()
    if #entries == 0 then entries = { action_state.get_selected_entry() } end
    require('telescope.actions').close(prompt_bufnr)
    for _, entry in ipairs(entries) do
      local path = entry.path or entry.filename or (type(entry.value) == 'string' and entry.value) or nil
      if path and vim.fn.isabsolutepath(path) == 0 then path = vim.fs.joinpath(entry.cwd or vim.uv.cwd(), path) end
      if path and vim.uv.fs_stat(path) then
        open_externally(path)
      else
        vim.notify('This entry is not a file on disk.', vim.log.levels.INFO)
      end
    end
  end

  require('telescope').setup {
    --  All the info you're looking for is in `:help telescope.setup()`
    defaults = {
      mappings = {
        i = { ['<C-o>'] = open_selection_externally },
        n = { ['<C-o>'] = open_selection_externally },
      },
    },
    pickers = {
      find_files = {
        hidden = true,
        file_ignore_patterns = { '%.git[/\\]' },
      },
    },
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }

  -- Enable Telescope extensions if they are installed
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  -- See `:help telescope.builtin`
  local builtin = require 'telescope.builtin'

  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

  -- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
  -- If you later switch picker plugins, this is where to update these mappings.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf

      -- Find references for the word under your cursor.
      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

      -- Jump to the implementation of the word under your cursor.
      -- Useful when your language has ways of declaring types without an actual implementation.
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

      -- Jump to the definition of the word under your cursor.
      -- This is where a variable was first declared, or where a function is defined, etc.
      -- To jump back, press <C-t>.
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

      -- Fuzzy find all the symbols in your current document.
      -- Symbols are things like variables, functions, types, etc.
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

      -- Fuzzy find all the symbols in your current workspace.
      -- Similar to document symbols, except searches over your entire project.
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

      -- Jump to the type of the word under your cursor.
      -- Useful when you're not sure what type a variable is and you want to see
      -- the definition of its *type*, not where it was *defined*.
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })

  -- Override default behavior and theme when searching
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 0,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- It's also possible to pass additional configuration options.
  --  See `:help telescope.builtin.live_grep()` for information about particular keys
  vim.keymap.set(
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    { desc = '[S]earch [/] in Open Files' }
  )

  -- Shortcut for searching your Neovim configuration files
  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[S]earch [N]eovim files' })
end

-- ============================================================
-- SECTION 6: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
do
  -- [[ LSP Configuration ]]
  -- Brief aside: **What is LSP?**
  --
  -- LSP is an initialism you've probably heard, but might not understand what it is.
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- In general, you have a "server" which is some tool built to understand a particular
  -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
  -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  -- processes that communicate with some "client" - in this case, Neovim!
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim. This is where `mason` and related plugins come into play.
  --
  -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
  -- and elegantly composed help section, `:help lsp-vs-treesitter`

  -- Useful status updates for LSP.
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {}

  --  This function gets run when an LSP attaches to a particular buffer.
  --    That is to say, every time a new file is opened that is associated with
  --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  --    function will be executed to configure the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      -- NOTE: Remember that Lua is a real programming language, and as such it is possible
      -- to define small helper and utility functions so you don't have to repeat yourself.
      --
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Rename the variable under your cursor.
      --  Most Language Servers support renaming across files, etc.
      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header.
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --  See `:help lsp-config` for information about keys and how to configure
  ---@type table<string, vim.lsp.Config>
  local servers = {
    -- clangd = {},
    gopls = { settings = { gopls = { templateExtensions = { 'gotmpl', 'gotmpls' } } } },
    ty = {}, -- Python type checking and navigation
    ruff = {}, -- Python linting and formatting
    tailwindcss = {
      -- Launch the Windows user-local npm install directly through Node.
      cmd = is_windows and {
        'node',
        vim.env.USERPROFILE .. '/.local/tailwindcss/node_modules/@tailwindcss/language-server/bin/tailwindcss-language-server',
        '--stdio',
      } or nil,
    },
    -- tsc = {},
    --
    -- Some languages (like rust) have entire language plugins that can be useful:
    --    https://github.com/mrcjkb/rustaceanvim
    --
    -- But for many setups, the LSP (`rust_analyzer`) will work just fine
    -- rust_analyzer = {},

    -- Mason does not install tools automatically on Windows. Enable StyLua there if it is on PATH.
    stylua = (not is_windows or vim.fn.executable 'stylua' == 1) and {} or nil,

    -- Special Lua Config, as recommended by neovim help docs
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
        client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
            --  See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.api.nvim_get_runtime_file('', true),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- Disable formatting (formatting is done by stylua)
        },
      },
    },
  }

  vim.pack.add { gh 'neovim/nvim-lspconfig' }

  -- The Windows laptop uses manually installed language tools on PATH.
  if not is_windows then
    vim.pack.add {
      gh 'mason-org/mason.nvim',
      gh 'mason-org/mason-lspconfig.nvim',
      gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
    }

    require('mason').setup {}
    -- The loop below enables language servers on both platforms.
    require('mason-lspconfig').setup { automatic_enable = false }

    local ensure_installed = vim.tbl_keys(servers)
    vim.list_extend(ensure_installed, {
      -- You can add other tools here that you want Mason to install.
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }
  end

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- ============================================================
-- SECTION 7: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
  -- [[ Formatting ]]
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- You can specify filetypes to autoformat on save here:
      local enabled_filetypes = {
        -- lua = true,
        -- python = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
    },
    -- You can also specify external formatters in here.
    formatters_by_ft = {
      -- rust = { 'rustfmt' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
end

-- ============================================================
-- SECTION 8: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================
do
  -- Blink uses Neovim's built-in snippet engine on Windows.
  if not is_windows then
    vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
    require('luasnip').setup {}

    -- `friendly-snippets` contains premade snippets: https://github.com/rafamadriz/friendly-snippets
    -- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
    -- require('luasnip.loaders.from_vscode').lazy_load()
  end

  -- [[ Autocomplete Engine ]]
  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See `:help blink-cmp-config-keymap` for defining your own keymap
      preset = 'default',

      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },

    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },

    snippets = { preset = is_windows and 'default' or 'luasnip' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See `:help blink-cmp-config-fuzzy` for more information
    fuzzy = { implementation = 'lua' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  }
end

-- ============================================================
-- SECTION 9: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
  -- [[ Configure Treesitter ]]
  --  Used to highlight, edit, and navigate code
  --
  --  See `:help nvim-treesitter-intro`

  vim.filetype.add { extension = { gotmpl = 'gotmpl', gotmpls = 'gotmpl', jinja2 = 'jinja', j2 = 'jinja' } }

  -- NOTE: You can also specify a branch or a specific commit
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- Ensure basic parsers are installed
  local parsers = basic_treesitter_parsers
  if is_windows then parsers = vim.tbl_filter(function(name) return windows_parser_paths[name] ~= nil end, parsers) end
  if #parsers > 0 then require('nvim-treesitter').install(parsers) end

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- Check if the buffer is valid (might not be after install completes)
    if not vim.api.nvim_buf_is_valid(buf) then return end

    -- Check if a parser exists and load it
    if not vim.treesitter.language.add(language) then return end

    -- Enable syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)

    -- Enable treesitter based folds
    -- For more info on folds see `:help folds`
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- vim.wo.foldmethod = 'expr'

    -- Check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

    -- Enable treesitter based indentation
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        -- Enable the parser if it is already installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) and (not is_windows or windows_parser_paths[language]) then
        -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- Try an existing parser, including parsers bundled with Neovim.
        treesitter_try_attach(buf, language)
      end
    end,
  })

  vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }
  local markdown_options = {}
  if not vim.g.have_nerd_font then
    -- Render headings, tables, and checkboxes with ordinary characters.
    markdown_options = {
      sign = { enabled = false },
      heading = { icons = {} },
      code = { language_icon = false },
      checkbox = {
        unchecked = { icon = '[ ]' },
        checked = { icon = '[x]' },
        custom = { todo = { rendered = '[-]' } },
      },
      link = { enabled = false },
      quote = { enabled = false },
    }
  end
  require('render-markdown').setup(markdown_options)
  vim.keymap.set('n', '<leader>tm', '<cmd>RenderMarkdown toggle<CR>', { desc = '[T]oggle [M]arkdown rendering' })
end

-- ============================================================
-- SECTION 10: OPTIONAL EXAMPLES / NEXT STEPS
-- kickstart.plugins.* examples
-- ============================================================
do
  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug'
  -- require 'kickstart.plugins.indent_line'
  -- require 'kickstart.plugins.lint'
  -- require 'kickstart.plugins.autopairs'
  -- require 'kickstart.plugins.neo-tree'

  -- NOTE: You can add your own plugins, configuration, etc. in `lua/custom/plugins/*.lua`.
  --
  -- For independent modules, uncomment the convenience loader:
  -- require 'custom.plugins'
  --
  -- `custom.plugins` automatically loads files from that directory, but their
  -- order is unspecified. If plugins depend on each other, keep them in the same
  -- file and put their `vim.pack.add()` and `setup()` calls in the required order.
  --
  -- If separate modules need a specific order, require them explicitly instead:
  -- require 'custom.plugins.colorscheme'
  -- require 'custom.plugins.ui'
  -- require 'custom.plugins.git'
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
