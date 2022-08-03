local awesome = awesome
local round = require("gears.math").round
local gears_debug = require("gears.debug")
local xresources = {}
local fallback = {
  color0 = '#0a0707',
  color1 = '#58483F',
  color2 = '#8A2F17',
  color3 = '#A32B15',
  color4 = '#A34E1C',
  color5 = '#DE5D1B',
  color6 = '#CC4022',
  color7 = '#efd191',
  color8 = '#a79265',
  color9 = '#58483F',
  color10 = '#8A2F17',
  color11 = '#A32B15',
  color12 = '#A34E1C',
  color13 = '#DE5D1B',
  color14 = '#CC4022',
  color15 = '#efd191',
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