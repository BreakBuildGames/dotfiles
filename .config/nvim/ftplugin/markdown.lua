vim.cmd([[set nofoldenable]])
vim.opt.textwidth=80
vim.cmd([[setlocal spell spelllang=en_us]])

-- jump to next header and center it
vim.keymap.set("n", "<leader>j", "/# <CR>zt", { noremap = false })

-- jump to next header or link
vim.keymap.set("n", "<leader>n", "/# \\|]]\\|](<CR>", { noremap = false })

