vim.g.mapleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.clipboard = "unnamedplus"

vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>quit<CR>", { silent = true })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { silent = true })
