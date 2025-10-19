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
  },
}
