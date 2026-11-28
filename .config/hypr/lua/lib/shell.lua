local file = require("lib.file")
local apps = require("const.apps")
local notify = require("const.notify")

local M = {}

M.DIR = os.getenv("HOME") .. "/.config/hypr/scripts"

---@param value string|number
---@return string
local function quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

---@param name string
---@return string
function M.path(name)
	return string.format("%s/%s.sh", M.DIR, name)
end

---@param path string
---@param out string[]
---@param seen table<string, boolean>
---@return string[]
local function collect_uses(path, out, seen)
	local content = file.read(path) or ""

	for names in content:gmatch("#%s*@use%s+([^\n]+)") do
		for lib in names:gmatch("%S+") do
			if not seen[lib] then
				seen[lib] = true
				local lib_path = M.path("lib/" .. lib)
				collect_uses(lib_path, out, seen)
				out[#out + 1] = lib_path
			end
		end
	end

	return out
end

---@class ShellRunOpts
---@field args? (string|number)[]
---@field vars? table<string, string|number>

---@param name string
---@param opts? ShellRunOpts
function M.run(name, opts)
	opts = opts or {}
	local path = M.path(name)

	local vars = {
		ICON_DIR = notify.ICON_DIR,
		REPLACE_ID = notify.REPLACE_ID,
		FILE_MANAGER = apps.fileManager,
	}
	for key, value in pairs(opts.vars or {}) do
		vars[key] = value
	end

	local lines = {}
	for key, value in pairs(vars) do
		lines[#lines + 1] = key .. "=" .. quote(value)
	end
	for _, lib in ipairs(collect_uses(path, {}, {})) do
		lines[#lines + 1] = "source " .. quote(lib)
	end
	lines[#lines + 1] = "source " .. quote(path) .. ' "$@"'

	local argv = { "bash", "-c", quote(table.concat(lines, "\n")), quote(name) }
	for _, arg in ipairs(opts.args or {}) do
		argv[#argv + 1] = quote(arg)
	end

	hl.exec_cmd(table.concat(argv, " "))
end

return M
