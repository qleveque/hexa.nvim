local u = require("hex.utils")

M = {}

-- vim.cmd("hi HexLine guibg=black guifg=none")
vim.cmd("hi HexFocus guibg=red guifg=black")
vim.cmd("hi HexContext guibg=orange guifg=black")

M.ASCII_cursor = function(ASCII_buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local x, y, yc = u.HEX_to_ASCII_cursor(cursor)
  -- vim.api.nvim_buf_clear_highlight(ASCII_buf, 1, 0, -1)
  -- vim.api.nvim_buf_add_highlight(ASCII_buf, 1, HexLine, x, 0, -1)
  vim.api.nvim_buf_clear_highlight(ASCII_buf, 2, 0, -1)
  vim.api.nvim_buf_add_highlight(ASCII_buf, 2, 'HexContext', x, y, y+2)
  vim.api.nvim_buf_clear_highlight(ASCII_buf, 3, 0, -1)
  vim.api.nvim_buf_add_highlight(ASCII_buf, 3, 'HexFocus', x, yc, yc+1)
end

M.hex_cursor = function(HEX_buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local x, y, yc = u.ASCII_to_HEX_cursor(cursor)
  -- vim.api.nvim_buf_clear_highlight(HEX_buf, 1, 0, -1)
  -- vim.api.nvim_buf_add_highlight(HEX_buf, 1, 'HexLine', x, 0, -1)
  vim.api.nvim_buf_clear_highlight(HEX_buf, 2, 0, -1)
  vim.api.nvim_buf_add_highlight(HEX_buf, 2, 'HexContext', x, y, y+4)
  vim.api.nvim_buf_clear_highlight(HEX_buf, 3, 0, -1)
  vim.api.nvim_buf_add_highlight(HEX_buf, 3, 'HexFocus', x, yc, yc+2)
end

return M
