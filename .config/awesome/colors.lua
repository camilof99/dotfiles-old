local awesome = awesome
local round = require("gears.math").round
local gears_debug = require("gears.debug")
local xresources = {}
local fallback = {
  color0 = '#18090c',
  color1 = '#344754',
  color2 = '#5D5656',
  color3 = '#AA5741',
  color4 = '#9F6858',
  color5 = '#B18672',
  color6 = '#E29471',
  color7 = '#b2b9b7',
  color8 = '#7c8180',
  color9 = '#344754',
  color10 = '#5D5656',
  color11 = '#AA5741',
  color12 = '#9F6858',
  color13 = '#B18672',
  color14 = '#E29471',
  color15 = '#b2b9b7',
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