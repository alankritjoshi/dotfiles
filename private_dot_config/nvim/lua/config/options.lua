vim.g.snacks_animate = false

vim.g.minipairs_disable = true

vim.filetype.add({
  extension = {
    templ = "templ",
  },
})

local opt = vim.opt
opt.wrap = true
opt.listchars:append({ eol = "¬" })

opt.relativenumber = false
