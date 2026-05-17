local home = os.getenv("HOME")

package.path = package.path
    .. ";"
    .. home
    .. "/.config/hypr/hyprlua/lua/?.lua"
    .. ";"
    .. home
    .. "/.config/hypr/hyprlua/lua/?/init.lua"

require("monitor")
require("system-envs")
require("apps")
require("settings")
require("services")
require("binds")
require("rules")
require("plugins")
