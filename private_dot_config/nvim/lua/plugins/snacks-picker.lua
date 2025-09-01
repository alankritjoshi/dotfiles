return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
      sources = {
        files = {
          actions = {
            -- Search in selected files/directories
            ["ctrl-e"] = {
              function(picker, items)
                if #items == 0 then
                  return
                end

                local paths = {}
                for _, item in ipairs(items) do
                  local path = item.file and item.file.path or item.text
                  if path then
                    -- Check if it's a directory
                    local stat = vim.uv.fs_stat(path)
                    if stat and stat.type == "directory" then
                      table.insert(paths, path)
                    else
                      -- For files, get the directory
                      local dir = vim.fn.fnamemodify(path, ":h")
                      if not vim.tbl_contains(paths, dir) then
                        table.insert(paths, dir)
                      end
                    end
                  end
                end

                if #paths > 0 then
                  -- Search in the selected directories
                  Snacks.picker.grep({
                    cwd = paths[1],
                    prompt = "Grep in " .. vim.fn.fnamemodify(paths[1], ":t") .. " > ",
                  })
                end
              end,
              desc = "Search in selected directory",
            },
            -- Navigate to parent directory
            ["ctrl-a"] = {
              function(picker)
                local cwd = picker.opts.cwd or vim.uv.cwd()
                local parent = vim.fn.fnamemodify(cwd, ":h")
                if parent ~= cwd then
                  Snacks.picker.files({
                    cwd = parent,
                    prompt = "Files (" .. vim.fn.fnamemodify(parent, ":t") .. ") > ",
                  })
                end
              end,
              desc = "Go to parent directory",
            },
            -- Jump to CWD
            ["ctrl-y"] = {
              function()
                Snacks.picker.files({
                  cwd = vim.uv.cwd(),
                  prompt = "Files (cwd) > ",
                })
              end,
              desc = "Jump to current directory",
            },
          },
        },
        grep = {
          actions = {
            -- Search within grep results (filter)
            ["ctrl-r"] = {
              function(picker, items)
                if #items == 0 then
                  -- If no items selected, toggle live grep
                  local new_opts = vim.deepcopy(picker.opts)
                  new_opts.live = not (new_opts.live or false)
                  new_opts.prompt = (new_opts.live and "Live " or "") .. "Grep > "
                  Snacks.picker.grep(new_opts)
                else
                  -- If items selected, search within those files
                  local files = {}
                  local seen = {}
                  for _, item in ipairs(items) do
                    local file = item.file and item.file.path or (item.text and item.text:match("^([^:]+):"))
                    if file and not seen[file] then
                      table.insert(files, file)
                      seen[file] = true
                    end
                  end
                  if #files > 0 then
                    Snacks.picker.grep({
                      search_paths = files,
                      prompt = "Grep in " .. #files .. " files > ",
                    })
                  end
                end
              end,
              desc = "Toggle live grep / Search in results",
            },
            -- Search in selected directories from grep results
            ["ctrl-e"] = {
              function(picker, items)
                if #items == 0 then
                  return
                end

                local dirs = {}
                local seen = {}
                for _, item in ipairs(items) do
                  local file = item.file and item.file.path or (item.text and item.text:match("^([^:]+):"))
                  if file then
                    local dir = vim.fn.fnamemodify(file, ":h")
                    if not seen[dir] then
                      table.insert(dirs, dir)
                      seen[dir] = true
                    end
                  end
                end

                if #dirs > 0 then
                  Snacks.picker.grep({
                    cwd = dirs[1],
                    prompt = "Grep in " .. vim.fn.fnamemodify(dirs[1], ":t") .. " > ",
                  })
                end
              end,
              desc = "Search in result directories",
            },
          },
        },
      },
    })

    -- Add custom keymaps
    vim.keymap.set("n", "<leader>fd", function()
      -- Find directories and then search in selected one
      Snacks.picker.files({
        fd_opts = "--type d --hidden --exclude .git",
        prompt = "Directories > ",
        confirm = function(picker, item)
          if item and item.file then
            Snacks.picker.grep({
              cwd = item.file.path,
              prompt = "Grep in " .. vim.fn.fnamemodify(item.file.path, ":t") .. " > ",
            })
          end
        end,
      })
    end, { desc = "Find directory and search" })

    -- Search in a specific directory with a picker
    vim.keymap.set("n", "<leader>sD", function()
      vim.ui.input({ prompt = "Directory path: ", default = vim.uv.cwd() }, function(dir)
        if dir and dir ~= "" then
          local expanded = vim.fn.expand(dir)
          if vim.fn.isdirectory(expanded) == 1 then
            Snacks.picker.grep({
              cwd = expanded,
              prompt = "Grep in " .. vim.fn.fnamemodify(expanded, ":t") .. " > ",
            })
          else
            vim.notify("Directory not found: " .. expanded, vim.log.levels.ERROR)
          end
        end
      end)
    end, { desc = "Search in specific directory" })

    -- Quick search in parent directory
    vim.keymap.set("n", "<leader>s.", function()
      local parent = vim.fn.fnamemodify(vim.uv.cwd(), ":h")
      Snacks.picker.grep({
        cwd = parent,
        prompt = "Grep in parent > ",
      })
    end, { desc = "Search in parent directory" })

    return opts
  end,
}