local home = os.getenv("HOME")

package.path = package.path .. ";" .. home .. "/.config/hypr/lua/?.lua" .. ";" .. home .. "/.config/hypr/lua/?/init.lua"

require("monitor")
require("system-envs")
require("apps")
require("settings")
require("services")
require("binds")
require("rules")
require("plugins")

require("_silenttest")
