return {
  {
    "akinsho/bufferline.nvim",
    keys = {
      {
        "<leader>bp",
        "<Cmd>BufferLinePick<CR>",
        desc = "Pick Buffer",
      },
      {
        "<leader>ba",
        "<Cmd>BufferLineCloseOthers<CR><Cmd>bdelete<CR>",
        desc = "Delete Other Buffers",
      },
    },
    init = function()
      local bufline = require("catppuccin.groups.integrations.bufferline")
      function bufline.get()
        return bufline.get_theme()
      end
    end,
  },
}
