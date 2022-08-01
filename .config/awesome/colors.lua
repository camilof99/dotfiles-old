local awesome = awesome
local round = require("gears.math").round
local gears_debug = require("gears.debug")
local xresources = {}
local fallback = {
  color0 = '#0F0F0C',
  color1 = '#748B53',
  color2 = '#8FAF2D',
  color3 = '#92A52F',
  color4 = '#ADCA2A',
  color5 = '#9DA15C',
  color6 = '#CAD44F',
  color7 = '#a6bcc7',
  color8 = '#74838b',
  color9 = '#748B53',
  color10 = '#8FAF2D',
  color11 = '#92A52F',
  color12 = '#ADCA2A',
  color13 = '#9DA15C',
  color14 = '#CAD44F',
  color15 = '#a6bcc7',
}
function xresources.get_current_theme()
  local keys = { 'background', 'foreground' }
  for i=0,15 do table.insert(keys, "color"..i) end
  local colors = {}
  for _, key in ipairs(keys) do
    local color = awesome.xrdb_get_value("", key)
    color = fallback[key]
    colors[key] = color
  end
  return colors
end
return xresources