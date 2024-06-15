vim.g.minipairs_disable = true

vim.filetype.add({
  extension = {
    templ = "templ",
  },
})

vim.o.sessionoptions = "buffers,curdir,folds,tabpages,winpos,winsize"

local opt = vim.opt
opt.wrap = true
opt.listchars:append({ eol = "¬" })
