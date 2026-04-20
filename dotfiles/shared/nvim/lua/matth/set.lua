vim.g.mapleader = " "

if vim.fn.has("win32") == 1 and vim.fn.executable("zig") == 0 then
  local zig_glob = vim.fn.expand("~/AppData/Local/Microsoft/WinGet/Packages/zig.zig_*/zig-*/zig.exe")
  local zig_bins = vim.fn.glob(zig_glob, false, true)
  local zig_bin = zig_bins[1]
  if zig_bin and vim.fn.executable(zig_bin) == 1 then
    local zig_dir = vim.fn.fnamemodify(zig_bin, ":h")
    vim.env.PATH = zig_dir .. ";" .. vim.env.PATH
  end
end

vim.opt.number = true
vim.opt.termguicolors = true

vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")
