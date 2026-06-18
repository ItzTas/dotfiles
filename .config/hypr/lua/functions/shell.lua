local M = {}

function M.open_path()
	local apps = require("envs.apps")
	local fm = apps.fileManager

	if not fm or fm == "" then
		local utils = require("functions.utils")
		local desktop = utils.run_cmd("xdg-mime query default inode/directory")
		if desktop then
			fm = desktop:gsub("%.desktop%s*$", "")
		end
	end

	fm = (fm and fm ~= "") and fm or "nemo"

	return string.format(
		[=[
open_path() {
    local path="$1"
    local id

    id=$(hyprctl activeworkspace -j | jq -r '.id')

    if [[ -n "$id" && "$id" != "null" ]]; then
        hyprctl eval "hl.exec_cmd('%s \"$path\"', { workspace = '$id' })"
        return
    fi
    %s "$path"
}
]=],
		fm,
		fm
	)
end

---@return string
function M.open_on()
	return [=[
open_on() {
    local app="$1"
    local icon="$2"
    local title="$3"
    local body="$4"
    local path="$5"

    local action
    action=$(dunstify -a "$app" -I "$icon" \
        --action="copy_path,copy path" \
        --action="default,open" \
        --action="copy,copy" \
        "$title" "$body")

    case "$action" in
    "default" | "open")
        open_path "$path"
        ;;
    "copy_path")
        wl-copy "$path"
        ;;
    "copy")
        wl-copy --type "$(file -b --mime-type "$path")" < "$path"
        ;;
    esac
}
]=]
end

---@class InjectOpts
---@field position? "before" | "after"
---@param deps (fun(): string | string)[]
---@param cmd string
---@param opts? InjectOpts
---@return string
function M.inject(deps, cmd, opts)
	local position = opts and opts.position or "before"

	local parts = {}
	for _, dep in ipairs(deps) do
		if type(dep) == "function" then
			parts[#parts + 1] = dep()
		else
			parts[#parts + 1] = dep
		end
	end

	if position == "after" then
		table.insert(parts, 1, cmd)
	else
		parts[#parts + 1] = cmd
	end

	return table.concat(parts)
end

return M
