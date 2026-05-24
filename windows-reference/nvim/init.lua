require("config.lazy")
vim.opt.guifont = "JetBrains Mono:h12"
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local opt = vim.opt
opt.termguicolors = true
vim.cmd('syntax on')

opt.scrolloff      = 5
opt.timeout        = false        -- .ideavimrc: set notimeout
opt.visualbell     = true         -- .ideavimrc: set visualbell
opt.errorbells     = false
opt.incsearch      = true
opt.hlsearch       = true
opt.number         = true
opt.relativenumber = true
opt.clipboard      = 'unnamedplus' -- .ideavimrc: set clipboard+=unnamed

-- nvim-only convenience
opt.showmatch  = true
opt.ignorecase = true
opt.smartcase  = true
opt.mouse      = 'a'
opt.tabstop    = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab  = true
opt.foldmethod = 'indent'
opt.foldlevel  = 99

-- 💡 辅助函数：自动附加 silent=true，极大简化原生的映射写法
local function map(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { silent = true })
end

map('n', '<Esc>', '<Cmd>nohlsearch<CR><Esc>')
map('n', '<leader>df', '[[^Vf{%d')
map('n', '<leader>yf', '[[^Vf{%y')
map('n', '<leader>vf', '[[^Vf{%')


-- Insert-mode 辅助 (mirror imap <C-V> <C-R>*)
map('i', '<C-v>', '<C-r>*')

-- Highlight on yank (mirror set highlightedyank)
vim.api.nvim_set_hl(0, 'YankHighlight', { bg = '#FFFF00', fg = 'NONE' })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'YankHighlight', timeout = 1000 })
  end,
})

-- ============================================================
-- VSCode Integration
-- ============================================================
if vim.g.vscode then
  local vscode = require('vscode')

  -- 💡 智能辅助函数：如果是字符串就当作 action 执行；如果是函数则直接绑定
  local function vsc_map(mode, lhs, action_or_fn)
    local rhs = type(action_or_fn) == "string" 
                and function() vscode.action(action_or_fn) end 
                or action_or_fn
    vim.keymap.set(mode, lhs, rhs, { silent = true })
  end

  -- UI Toggle
  vsc_map('n', '<Leader>z', 'workbench.action.toggleZenMode')
  vsc_map('n', '<C-,>',     'workbench.action.openSettings')

  -- Navigation
  vsc_map('n', '[d',  'editor.action.marker.prevInFiles')
  vsc_map('n', ']d',  'editor.action.marker.nextInFiles')
  vsc_map('n', '[c',  'workbench.action.editor.previousChange')
  vsc_map('n', ']c',  'workbench.action.editor.nextChange')
  -- [[ / ]] : 不覆盖，沿用 Vim 原生 section 跳转
  vsc_map('n', 'g;',  'workbench.action.navigateBackInEditLocations')
  vsc_map('n', 'g,',  'workbench.action.navigateForwardInEditLocations')
  vsc_map('n', 'gs',  'workbench.action.gotoSymbol')
  vsc_map('n', 'gS',  'workbench.action.showAllSymbols')
  vsc_map('n', 'gA',  'workbench.action.showCommands')
  vsc_map('n', 'gi',  'editor.action.goToSuperImplementation')
  vsc_map('n', 'gI',  'editor.action.goToImplementation')
  vsc_map('n', 'gu',  'references-view.findReferences')
  vsc_map('n', '<C-e>', 'workbench.action.quickOpen')

  -- Search & Replace
  vsc_map({ 'n', 'x' }, 'g/',        'workbench.action.findInFiles')
  vsc_map('n',          '<Leader>/', 'actions.find')
  vsc_map('n',          '<Leader>;', 'editor.action.startFindReplaceAction')

  -- Splits
  vsc_map('n', '<C-w>gd', 'editor.action.revealDefinitionAside')
  
  -- 支持传入复杂函数逻辑
  vsc_map('n', '<C-w>gD', function()
    vscode.call('workbench.action.splitEditor')
    vscode.call('editor.action.goToTypeDefinition')
  end)

  -- VCS / Git (require GitLens)
  vsc_map('n', '<Leader>ga', 'gitlens.toggleFileBlame')
  vsc_map('n', '<Leader>gh', 'gitlens.showQuickFileHistory')

  -- Bookmarks (require Bookmarks extension by Alessandro Fragnani)
  vsc_map('n', 'mm', 'bookmarks.toggle')
  vsc_map('n', 'ms', 'bookmarks.list')
  vsc_map('n', 'mS', 'bookmarks.listFromAllFiles')

  -- Breakpoints
  vsc_map('n', 'mb', 'editor.debug.action.toggleBreakpoint')
  vsc_map('n', 'me', 'editor.debug.action.editBreakpoint')
  vsc_map('n', 'mv', 'workbench.view.debug')

  -- Code edits / refactor
  vsc_map('n',          'cd',    'editor.action.rename')
  vsc_map('n',          '<A-u>', 'editor.action.refactor') -- VSCode 无原生 Unwrap
  vsc_map({ 'n', 'x' }, '<A-r>', 'editor.action.refactor')
  vsc_map({ 'n', 'i' }, '<A-v>', 'editor.action.refactor') -- VSCode 无原生 IntroduceVariable

  -- Code Hints
  vsc_map({ 'n', 'x', 'i' }, '<C-.>', 'editor.action.quickFix')
  vsc_map('n',               'gh',    'editor.action.showHover')
  vsc_map({ 'n', 'i' },      '<A-q>', 'editor.action.triggerParameterHints')
end
