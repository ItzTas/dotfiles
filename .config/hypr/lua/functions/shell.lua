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

    return string.format([=[
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
]=], fm, fm)
end

---@param deps (fun(): string | string)[]
---@param cmd string
---@return string
function M.inject(deps, cmd)
    local parts = {}
    for _, dep in ipairs(deps) do
        if type(dep) == "function" then
            parts[#parts + 1] = dep()
        else
            parts[#parts + 1] = dep
        end
    end
    parts[#parts + 1] = cmd
    return table.concat(parts)
end

return M
