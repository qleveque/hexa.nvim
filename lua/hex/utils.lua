local M = {}

M.int_div = function(dividend, divisor)
  return (dividend - (dividend % divisor)) / divisor
end

M.move_to_col = function(col)
  if col == nil then
    return
  end
  vim.cmd('normal! 0')
  if col > 0 then
    vim.cmd('normal! '..col..'l')
  end
end

M.is_window_open = function(window_id)
  if not vim.api.nvim_win_is_valid(window_id) then
    return false
  end
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    if win == window_id then
      return true
    end
  end
  return false
end

return M
