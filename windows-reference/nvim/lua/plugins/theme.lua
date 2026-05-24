return {
  "nickkadutskyi/jb.nvim",
  priority = 1000, -- 优先级设为最高，确保主题在其他插件之前加载
  config = function()
    -- 开启真彩色支持 (非常重要)
    vim.opt.termguicolors = true
    
    -- 关键：将背景设置为浅色，主题插件会自动切换到 JetBrains Light 模式
    vim.opt.background = "light"
    
    -- 启用 JetBrains 主题
    vim.cmd("colorscheme jb") 
  end,
}
