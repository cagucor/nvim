local status_ok, heirline = pcall(require, "heirline")
if not status_ok then
  return
end

local status_ok_1, catppuccin = pcall(require, "catppuccin.palettes")
if not status_ok_1 then
  return
end

local status_ok_2, utils = pcall(require, "heirline.utils")
if not status_ok_2 then
  return
end

local status_ok_3, conditions = pcall(require, "heirline.conditions")
if not status_ok_3 then
  return
end

local colors = catppuccin.get_palette "frappe"

local components = require "statusline.components"

heirline.load_colors(colors)

local statusline = {
  components.ViMode,
  components.Env,
  components.Diffs,
  components.Fill,
  components.FileInfo,
  components.LSP,
  components.CursorPos,
}

local winbar = {
  components.Exclude,
  components.FileIcon,
  components.FileName,
  components.FileFlags,
  components.Navic,
}

local tabline = {}

heirline.setup(statusline, winbar, tabline)
