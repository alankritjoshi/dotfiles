return {
  "bloznelis/before.nvim",
  config = function()
    local before = require("before")

    before.setup({
      telescope_for_preview = true,
    })

    -- Jump to previous entry in the edit history
    vim.keymap.set("n", "<M-h>", before.jump_to_last_edit, {})

    -- Jump to next entry in the edit history
    vim.keymap.set("n", "<M-l>", before.jump_to_next_edit, {})

    vim.keymap.set("n", "<leader>oe", function()
      before.show_edits(require("telescope.themes").get_dropdown())
    end, {})
  end,
}
