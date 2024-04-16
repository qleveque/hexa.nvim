# Hex.nvim
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

Simple hexadecimal editor for neovim.

![demo](https://github.com/qleveque/Hex.nvim/blob/main/resources/demo.gif?raw=true)

## Installation using lazy.nvim

```
  return {
    "qleveque/Hex.nvim",
    opts={}
  }
```

## Default configuration

```
{
  keymaps = {
    reformat_hex = '<leader>f',
    replace_ascii = 'r',
    undo_ascii = 'u',
    redo_ascii = '<C-R>',
    run = '<CR>',
  },
  run_cmd = function(file) return 'bot sp | term "'..file..'"' end
}
```

## Available commands
+ `:HexSearch`: performs a forward search ignoring spaces and newlines
+ `:HexSearchBack`: same as HexSearch, but backward
+ `:HexReformat`: properly reformats the hexa content
+ `:HexShow`: shows the line and ASCII windows
+ `:HexToggleBin`: switches between binary and hexa representation

## Usage

In zsh vi mode (`bindkey -v`) for both `vicmd` and `visual` modes:

+ <kbd>/</kbd> triggers `HexSearch` command
+ <kbd>?</kbd> triggers `HexSearchBack` command
+ <kbd>r</kbd> replace a single character in the ASCII representation
+ <kbd>Enter</kbd> runs the binary file

## Dependencies
This plugin requires `python3` and `xxd`.

## Credits
This plugin was inspired by Raafat Turki's [hex.nvim](https://github.com/RaafatTurki/hex.nvim) excellent plugin.
