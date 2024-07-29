return {
  {
    "leath-dub/snipe.nvim",
    opts = {},
    keys = {
      {
        "gb",
        function()
          local toggle = require("snipe").create_buffer_menu_toggler()
          toggle()
        end,
      },
    },
  },
}
