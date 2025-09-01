return {
  {
    "echasnovski/mini.pick",
    dependencies = {
      "echasnovski/mini.icons",
      "echasnovski/mini.extra",
    },
    config = function()
      local MiniPick = require("mini.pick")
      local MiniExtra = require("mini.extra")
      
      -- Set up mini.extra first
      MiniExtra.setup()
      
      -- Configure mini.pick
      MiniPick.setup({
        mappings = {
          choose = "<CR>",
          choose_in_split = "<C-s>",
          choose_in_tabpage = "<C-t>",
          choose_in_vsplit = "<C-v>",
          choose_marked = "<C-q>",
          delete_char = "<BS>",
          delete_char_right = "<Del>",
          delete_left = "<C-u>",
          delete_word = "<C-w>",
          mark = "<C-x>",
          mark_all = "<C-a>",
          move_down = "<C-j>",
          move_start = "<C-g>",
          move_up = "<C-k>",
          paste = "<C-v>",
          refine = "<C-r>",
          refine_marked = "<C-R>",
          scroll_down = "<C-f>",
          scroll_left = "<C-h>",
          scroll_right = "<C-l>",
          scroll_up = "<C-b>",
          stop = "<Esc>",
          toggle_info = "<S-Tab>",
          toggle_preview = "<C-p>",
          
          -- Custom mappings to match snacks functionality
          cwd_backward = "<M-h>",  -- Go to parent directory
          cwd_forward = "<M-l>",   -- Go into directory
        },
        options = {
          use_cache = true,
          content_from_bottom = false,
        },
        source = {
          show = MiniPick.default_show,
        },
        window = {
          config = {
            border = "rounded",
            winblend = 0,
          },
          prompt_cursor = "█",
          prompt_prefix = "> ",
        },
      })
      
      -- Set up mini.icons for file icons
      require("mini.icons").setup()
      
      -- Helper functions
      local function grep_in_directory(dir, prompt_prefix)
        prompt_prefix = prompt_prefix or ("Grep in " .. vim.fn.fnamemodify(dir, ":t") .. " > ")
        MiniPick.builtin.grep_live({
          cwd = dir,
          source = {
            name = prompt_prefix,
          },
        })
      end
      
      local function files_in_directory(dir, prompt_prefix)
        prompt_prefix = prompt_prefix or ("Files (" .. vim.fn.fnamemodify(dir, ":t") .. ") > ")
        MiniPick.builtin.files({
          cwd = dir,
          source = {
            name = prompt_prefix,
          },
        })
      end
      
      -- Custom actions for files picker
      local files_with_actions = function(opts)
        opts = opts or {}
        local original_choose = opts.source and opts.source.choose
        
        opts.source = vim.tbl_deep_extend("force", opts.source or {}, {
          choose = function(item)
            if original_choose then
              return original_choose(item)
            end
            -- Default: open file
            MiniPick.default_choose(item)
          end,
        })
        
        -- Add custom mappings
        opts.mappings = vim.tbl_deep_extend("force", opts.mappings or {}, {
          -- Search in selected directory (ctrl-e equivalent)
          search_in_dir = {
            char = "<C-e>",
            func = function()
              local items = MiniPick.get_picker_matches()
              local current = MiniPick.get_picker_items()[items.current]
              if current then
                local path = type(current) == "string" and current or current.path or current.text
                if path then
                  local stat = vim.uv.fs_stat(path)
                  if stat then
                    if stat.type == "directory" then
                      MiniPick.set_picker_target_window(MiniPick.get_picker_opts().target_window)
                      MiniPick.stop()
                      grep_in_directory(path)
                    else
                      local dir = vim.fn.fnamemodify(path, ":h")
                      MiniPick.set_picker_target_window(MiniPick.get_picker_opts().target_window)
                      MiniPick.stop()
                      grep_in_directory(dir)
                    end
                  end
                end
              end
            end,
          },
          -- Navigate to parent directory (ctrl-a equivalent)
          parent_dir = {
            char = "<C-a>",
            func = function()
              local picker_opts = MiniPick.get_picker_opts()
              local cwd = picker_opts.cwd or vim.uv.cwd()
              local parent = vim.fn.fnamemodify(cwd, ":h")
              if parent ~= cwd then
                MiniPick.set_picker_target_window(picker_opts.target_window)
                MiniPick.stop()
                files_in_directory(parent)
              end
            end,
          },
          -- Jump to CWD (ctrl-y equivalent)
          jump_cwd = {
            char = "<C-y>",
            func = function()
              local picker_opts = MiniPick.get_picker_opts()
              MiniPick.set_picker_target_window(picker_opts.target_window)
              MiniPick.stop()
              files_in_directory(vim.uv.cwd(), "Files (cwd) > ")
            end,
          },
        })
        
        return MiniPick.builtin.files(opts)
      end
      
      -- Custom actions for grep picker
      local grep_with_actions = function(opts)
        opts = opts or {}
        
        -- Add custom mappings
        opts.mappings = vim.tbl_deep_extend("force", opts.mappings or {}, {
          -- Toggle live grep / Search in results (ctrl-r equivalent)
          toggle_or_filter = {
            char = "<C-r>",
            func = function()
              local items = MiniPick.get_picker_matches()
              local marked = MiniPick.get_picker_matches().marked
              
              if #marked > 0 then
                -- Search within marked files
                local files = {}
                local seen = {}
                for _, idx in ipairs(marked) do
                  local item = MiniPick.get_picker_items()[idx]
                  local file = type(item) == "string" and item:match("^([^:]+):") or (item.path or item.file)
                  if file and not seen[file] then
                    table.insert(files, file)
                    seen[file] = true
                  end
                end
                if #files > 0 then
                  MiniPick.stop()
                  MiniPick.builtin.grep_live({
                    source = {
                      name = "Grep in " .. #files .. " files > ",
                      items = files,
                    },
                  })
                end
              else
                -- Toggle between grep and grep_live
                local picker_opts = MiniPick.get_picker_opts()
                MiniPick.stop()
                -- If current is grep_live, switch to grep, otherwise switch to grep_live
                if picker_opts.source and picker_opts.source.name and picker_opts.source.name:match("Live") then
                  MiniPick.builtin.grep(picker_opts)
                else
                  MiniPick.builtin.grep_live(picker_opts)
                end
              end
            end,
          },
          -- Search in result directories (ctrl-e equivalent)
          search_in_result_dirs = {
            char = "<C-e>",
            func = function()
              local marked = MiniPick.get_picker_matches().marked
              local dirs = {}
              local seen = {}
              
              local indices = #marked > 0 and marked or { MiniPick.get_picker_matches().current }
              
              for _, idx in ipairs(indices) do
                local item = MiniPick.get_picker_items()[idx]
                local file = type(item) == "string" and item:match("^([^:]+):") or (item.path or item.file)
                if file then
                  local dir = vim.fn.fnamemodify(file, ":h")
                  if not seen[dir] then
                    table.insert(dirs, dir)
                    seen[dir] = true
                  end
                end
              end
              
              if #dirs > 0 then
                MiniPick.stop()
                grep_in_directory(dirs[1])
              end
            end,
          },
        })
        
        return MiniPick.builtin.grep_live(opts)
      end
      
      -- Custom picker for directories
      local pick_directory_and_grep = function()
        local items = vim.fn.systemlist("fd --type d --hidden --exclude .git")
        MiniPick.start({
          source = {
            items = items,
            name = "Directories > ",
            choose = function(item)
              grep_in_directory(item)
            end,
          },
        })
      end
      
      -- Main keymaps
      vim.keymap.set("n", "<leader>ff", function() files_with_actions() end, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", function() grep_with_actions() end, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fb", MiniPick.builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", MiniPick.builtin.help, { desc = "Help" })
      vim.keymap.set("n", "<leader>fr", function() MiniExtra.pickers.oldfiles() end, { desc = "Recent Files" })
      vim.keymap.set("n", "<leader>fc", function() MiniExtra.pickers.commands() end, { desc = "Commands" })
      vim.keymap.set("n", "<leader>fk", function() MiniExtra.pickers.keymaps() end, { desc = "Keymaps" })
      vim.keymap.set("n", "<leader>fm", function() MiniExtra.pickers.marks() end, { desc = "Marks" })
      vim.keymap.set("n", "<leader>fd", pick_directory_and_grep, { desc = "Find directory and search" })
      
      -- Git pickers
      vim.keymap.set("n", "<leader>gc", function() MiniExtra.pickers.git_commits() end, { desc = "Git Commits" })
      vim.keymap.set("n", "<leader>gs", function() MiniExtra.pickers.git_files() end, { desc = "Git Status" })
      
      -- LSP pickers
      vim.keymap.set("n", "<leader>ss", function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end, { desc = "Document Symbols" })
      vim.keymap.set("n", "<leader>sS", function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end, { desc = "Workspace Symbols" })
      
      -- Search in specific directory
      vim.keymap.set("n", "<leader>sD", function()
        vim.ui.input({ prompt = "Directory path: ", default = vim.uv.cwd() }, function(dir)
          if dir and dir ~= "" then
            local expanded = vim.fn.expand(dir)
            if vim.fn.isdirectory(expanded) == 1 then
              grep_in_directory(expanded)
            else
              vim.notify("Directory not found: " .. expanded, vim.log.levels.ERROR)
            end
          end
        end)
      end, { desc = "Search in specific directory" })
      
      -- Quick search in parent directory
      vim.keymap.set("n", "<leader>s.", function()
        local parent = vim.fn.fnamemodify(vim.uv.cwd(), ":h")
        grep_in_directory(parent, "Grep in parent > ")
      end, { desc = "Search in parent directory" })
    end,
  },
}