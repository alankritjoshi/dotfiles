return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "sindrets/diffview.nvim",
    },
    keys = {
      {
        "<leader>gt",
        -- "<cmd>Neogit kind=split_above<CR>",
        function()
          local function is_buffer_empty()
            local bufnr = vim.api.nvim_get_current_buf()
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            if line_count == 1 then
              local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
              if lines[1] == "" then
                return true
              end
            end
            return false
          end
          -- Check if there are any open buffers
          if vim.bo.filetype == "dashboard" or is_buffer_empty() then
            -- If no open buffers, run Neogit command
            vim.cmd("Neogit")
          else
            -- If there are open buffers, run the original command
            vim.cmd("Neogit kind=split_above")
          end
        end,
        desc = "Neogit",
      },
    },
  },
}
