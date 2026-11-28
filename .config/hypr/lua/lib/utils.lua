local M = {}

---@class CmdResult
---@field stdout string|nil
---@field stderr string|nil
---@field exit_code integer

---@param cmd string
---@return CmdResult
function M.run_cmd_full(cmd)
	local tmp = os.tmpname()

	local handle = io.popen(cmd .. " 2>" .. tmp)

	if not handle then
		return {
			stdout = nil,
			stderr = "failed to start process",
			exit_code = -1,
		}
	end

	local stdout = handle:read("*a")

	local ok, _, code = handle:close()

	local err_handle = io.open(tmp, "r")
	local stderr = nil

	if err_handle then
		stderr = err_handle:read("*a")
		err_handle:close()
	end

	os.remove(tmp)

	return {
		stdout = stdout ~= "" and stdout or nil,
		stderr = stderr ~= "" and stderr or nil,
		exit_code = ok and 0 or (code or 1),
	}
end

function M.run_cmd(cmd)
	local h = io.popen(cmd)
	if not h then
		return nil
	end

	local out = h:read("*a")
	h:close()

	return (out and out ~= "") and out or nil
end

---@param cmd string
function M.run_async_cmd(cmd)
	hl.exec_cmd("bash -c '" .. cmd:gsub("'", "'\\''") .. "'")
end

---@param fn function
---@param timeout integer|nil
function M.defer(fn, timeout)
	hl.timer(fn, { timeout = timeout or 1, type = "oneshot" })
end

function M.memoize(fn)
	local result
	local computed = false
	return function()
		if not computed then
			result = fn()
			computed = true
		end
		return result
	end
end

return M
