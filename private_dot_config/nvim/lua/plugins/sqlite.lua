return {
  {
    "kkharji/sqlite.lua",
    config = function()
      -- Find SQLite library from nix or system
      local function find_sqlite_lib()
        -- Try to find from nix first
        local nix_sqlite = vim.fn.glob("/nix/store/*/lib/libsqlite3.dylib")
        if nix_sqlite ~= "" then
          -- Get the first match if multiple found
          local libs = vim.split(nix_sqlite, "\n")
          if #libs > 0 and libs[1] ~= "" then
            return libs[1]
          end
        end
        
        -- Fallback to system SQLite
        if vim.fn.filereadable("/usr/lib/libsqlite3.dylib") == 1 then
          return "/usr/lib/libsqlite3.dylib"
        end
        
        -- Try Homebrew location as last resort
        if vim.fn.filereadable("/opt/homebrew/opt/sqlite/lib/libsqlite3.dylib") == 1 then
          return "/opt/homebrew/opt/sqlite/lib/libsqlite3.dylib"
        end
        
        return nil
      end
      
      local lib_path = find_sqlite_lib()
      if lib_path then
        vim.g.sqlite_clib_path = lib_path
      else
        vim.notify("SQLite library not found. yanky.nvim SQLite storage may not work.", vim.log.levels.WARN)
      end
    end,
  },
}