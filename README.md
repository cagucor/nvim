# Neovim as and IDE

## Try out this config

Make sure to remove or move your current `nvim` directory

```
git clone https://github.com/cagucor/nvim.git ~/.config/nvim
```

Run `nvim` and wait for the plugins to be installed 

**NOTE:** (You will notice treesitter pulling in a bunch of parsers the next time you open Neovim) 

There is an install script for getting the latest neovim version. 
See the neovim repository for build dependencies.

## Get healthy

Open `nvim` and enter the following:

```
:checkhealth
```

You'll probably notice you don't have support for copy/paste also that python and node haven't been setup

So let's fix that

First we'll fix copy/paste

- On mac `pbcopy` should be builtin

- On Ubuntu

  ```
  sudo apt install xsel
  ```

- On Arch Linux

  ```
  sudo pacman -S xsel
  ```

Next we need to install python support (node is optional)

- Neovim python support

  ```
  pip install pynvim
  ```

- Neovim node support

  ```
  npm i -g neovim
  ```

## Fonts

- [A nerd font](https://github.com/ryanoasis/nerd-fonts)
- [codicon](https://github.com/microsoft/vscode-codicons/raw/main/dist/codicon.ttf)
- [An emoji font](https://github.com/googlefonts/noto-emoji/blob/main/fonts/NotoColorEmoji.ttf)

After moving fonts to `~/.local/share/fonts/`

Run: `$ fc-cache -f -v`

**NOTE:** (If you are seeing boxes without icons, try changing this line from `false` to `true`: [link](https://github.com/ChristianChiarulli/nvim/blob/ac41efa237caf3a498077df19a3f31ca4b35caf3/lua/user/icons.lua#L5))
