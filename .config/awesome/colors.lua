local awesome = awesome
local round = require("gears.math").round
local gears_debug = require("gears.debug")
local xresources = {}
local fallback = {
  color0 = '#0E0E12',
  color1 = '#394651',
  color2 = '#3B4F66',
  color3 = '#4E5C68',
  color4 = '#95363E',
  color5 = '#395385',
  color6 = '#637787',
  color7 = '#afbec6',
  color8 = '#7a858a',
  color9 = '#394651',
  color10 = '#3B4F66',
  color11 = '#4E5C68',
  color12 = '#95363E',
  color13 = '#395385',
  color14 = '#637787',
  color15 = '#afbec6',
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