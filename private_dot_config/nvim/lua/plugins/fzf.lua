return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "echasnovski/mini.icons" },
    keys = {
      {
        "<leader>fd",
        function()
          require("fzf-lua").files({
            cwd = vim.fn.getcwd(),
            fd_opts = "--type d --hidden",
            prompt = "Directories❯ ",
          })
        end,
        desc = "Search Directories in CWD",
      },
    },
    config = function()
      local fzf_lua = function()
        return require("fzf-lua")
      end

      fzf_lua().setup({
        winopts = {
          preview = {
            layout = "vertical",
            vertical = "down:60%",
          },
        },
        grep = {
          rg_glob = true,
          actions = {
            ["ctrl-r"] = { fzf_lua().actions.grep_lgrep },
            ["ctrl-g"] = { fzf_lua().actions.toggle_ignore },
            ["ctrl-e"] = {
              function(selected, opts)
                local files = {}
                local seen_files = {}
                for _, item in ipairs(selected) do
                  local file = item:match("([^:]+)")

                  if file:match("[/\\]") then
                    local entry = fzf_lua().path.entry_to_file(file)

                    if not seen_files[entry.stripped] then
                      table.insert(files, entry.stripped)
                      seen_files[entry.stripped] = true
                    end
                  end
                end

                if #files == 0 then
                  fzf_lua().files({
                    fd_opts = opts.fd_opts,
                    prompt = opts.prompt,
                  })
                else
                  fzf_lua().live_grep({
                    search_paths = files,
                    prompt = "*Rg(" .. table.concat(files, ", ") .. ")> ",
                  })
                end
              end,
            },
          },
        },
        files = {
          actions = {
            ["ctrl-e"] = {
              function(selected, opts)
                local files = {}
                for _, file in ipairs(selected) do
                  local entry = fzf_lua().path.entry_to_file(file)
                  table.insert(files, entry.stripped)
                end

                if #files == 0 then
                  fzf_lua().files({
                    fd_opts = opts.fd_opts,
                    prompt = opts.prompt,
                  })
                else
                  fzf_lua().live_grep({
                    search_paths = files,
                    prompt = "*Rg(" .. table.concat(files, ", ") .. ")> ",
                  })
                end
              end,
            },
            ["ctrl-a"] = {
              function(_, opts)
                fzf_lua().files({
                  cwd = vim.fn.fnamemodify(vim.fs.normalize(opts.cwd or vim.uv.cwd()), ":h"),
                  fd_opts = opts.fd_opts,
                  prompt = opts.prompt,
                })
              end,
            },
            ["ctrl-y"] = {
              function(_, opts)
                fzf_lua().files({
                  cwd = vim.uv.cwd(),
                  fd_opts = opts.fd_opts,
                  prompt = opts.prompt,
                })
              end,
            },
          },
        },
      })
    end,
  },
}
