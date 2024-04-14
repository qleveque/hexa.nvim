local refs = require("hex.references")

local M = {}

local current_script = debug.getinfo(1, "S").source:sub(2)
local current_path = vim.fn.fnamemodify(current_script, ":h")

M.dump_HEX = function(file)
  local HEX_file = refs.get_HEX_file(file)
  vim.fn.system(current_path.."/scripts/dump_hex "..file.." "..HEX_file)
end

M.dump_ASCII = function(file)
  local ASCII_file = refs.get_ASCII_file(file)
  vim.fn.system(current_path.."/scripts/dump_ascii "..file.." "..ASCII_file)
end

M.update = function(file)
  local HEX_file = refs.get_HEX_file(file)
  vim.fn.system(current_path.."/scripts/update "..file.." "..HEX_file)
end

return M
