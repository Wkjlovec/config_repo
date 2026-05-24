return {
  {
    "phaazon/hop.nvim",
    branch = "v2", -- 强烈建议指定分支，避免未来兼容问题
    config = function()
      require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
      local hop = require("hop")
      local directions = require("hop.hint").HintDirection
      vim.keymap.set('n', '<leader>f', ":HopChar1<CR>", {silent=true})
    end
  }
}
