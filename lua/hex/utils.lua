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

return M
