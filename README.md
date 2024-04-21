# hexa.nvim
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

Simple hexadecimal editor for neovim.

![demo](https://github.com/qleveque/hexa.nvim/blob/main/resources/demo.gif?raw=true)

## Installation using lazy.nvim

```
  return {
    "qleveque/hexa.nvim",
    opts={}
  }
```

## Default configuration

```
{
  keymaps = {
    hex = {
      reformat = '<leader>f',
    },
    ascii = {
      replace = 'r',
      undo = 'u',
      redo = '<C-R>',
    },
    run = '<CR>',
  },
  run_cmd = function(file) return 'bot sp | term "'..file..'"' end,
  ascii_left = false,
}
```

## Available commands
+ `:HexSearch`: performs a forward search ignoring spaces and newlines
+ `:HexSearchBack`: same as `HexSearch`, but backward
+ `:HexReformat`: properly reformats the hexa content
+ `:HexShow`: shows the address and ASCII windows
+ `:HexToggleBin`: switches between binary and hexa representation
+ `:HexRun`: runs the binary file
+ `:HexGoto`: goes to the given hexa position
+ `:Hex`: open current file as a binary file
+ `:UnHex`: open original file

## Usage

+ <kbd>/</kbd> triggers the `HexSearch` command
+ <kbd>?</kbd> triggers the `HexSearchBack` command
+ <kbd>Enter</kbd> triggers the `HexRun` command
+ <kbd>r</kbd> replace a single character in the ASCII representation

## Dependencies
This plugin requires `python3` and `xxd`.

## Credits
This plugin was inspired by Raafat Turki's [hex.nvim](https://github.com/RaafatTurki/hex.nvim) excellent plugin.
