return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      
      mc.setup()
      local set = vim.keymap.set

      set({"n", "v"}, "gl", function()
        local mode = vim.fn.mode()
        if mode == "n" and not mc.hasCursors() then vim.cmd("normal! viw")
        else mc.matchAddCursor(1)
        end
      end, { desc = "Multicursor: Select word or add next match" })

      set({"n", "v"}, "ga", function() mc.matchAllAddCursors() end, { desc = "Multicursor: Select all matches" })

      set({"n", "v"}, "g>", function() mc.matchSkipCursor(1) end, { desc = "Multicursor: Skip current and match next" })

      set({"n", "v"}, "g<", function() mc.deleteCursor() end, { desc = "Multicursor: Delete current cursor" })

      set("n", "<esc>", function()
        if not mc.cursorsEnabled() then mc.enableCursors()
        elseif mc.hasCursors() then mc.clearCursors()
        else vim.cmd("nohls")
        end
      end, { desc = "Clear multicursors or clear hlsearch" })
    end,
  },
}
