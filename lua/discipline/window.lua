local FLOAT_WIDTH = 60
local FLOAT_WIN_BTM_HEIGHT = 15
local FLOAT_WIN_TOP_HEIGHT = vim.o.window - FLOAT_WIN_BTM_HEIGHT
local PAD_BTM = 4

---
--- @return table
local function float_win_btm_opts()
	local width = FLOAT_WIDTH
	local row = vim.o.lines - (FLOAT_WIN_BTM_HEIGHT + PAD_BTM)

	return {
		anchor = "NE",
		border = "rounded",
		relative = "editor",
		width = width,
		height = FLOAT_WIN_BTM_HEIGHT,
		row = row,
		col = vim.o.columns,
		style = "minimal",
	}
end

--- @return table
local function float_win_top_opts()
	local width = FLOAT_WIDTH

	return {
		anchor = "NE",
		border = "rounded",
		relative = "editor",
		width = width,
		height = FLOAT_WIN_TOP_HEIGHT - PAD_BTM,
		row = 0,
		col = vim.o.columns,
		style = "minimal",
	}
end

local M = {}

--- @type integer|nil
M.window_id = nil
--- @type integer|nil
M.window_top_id = nil
--- @type integer|nil
M.window_id_scratch = nil
--- @type integer|nil
M.last_active_window_id = nil
--- @type integer|nil
M.previous_window_id = nil
--- @type integer|nil
M.previous_window_id_scratch = nil

M.switch_window = function()
	if M.window_id and vim.api.nvim_win_is_valid(M.window_id) then
		if vim.api.nvim_get_current_win() ~= M.window_id then
			vim.api.nvim_set_current_win(M.window_id)
			-- M.last_active_window_id = vim.api.nvim_get_current_win()
			return
		end
	end

	if M.window_top_id and vim.api.nvim_win_is_valid(M.window_top_id) then
		vim.api.nvim_set_current_win(M.window_top_id)
		if vim.api.nvim_get_current_win() ~= M.window_top_id then
			vim.api.nvim_set_current_win(M.window_top_id)
			-- M.last_active_window_id = vim.api.nvim_get_current_win()
			return
		end
	end

	vim.notify("No valid floating window to switch to.", vim.log.levels.WARN)
end


--- Shows `buf` in the shared floating window, creating the window if needed.
--- @param buf integer|nil
M.show_in_float = function(buf)
	if buf == nil then
		vim.notify("No buffer provided to show in floating window.", vim.log.levels.WARN)
		return
	end
	vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

	M.previous_window_id = vim.api.nvim_get_current_win()

	if M.window_id == nil or not vim.api.nvim_win_is_valid(M.window_id) then
		M.window_id = vim.api.nvim_open_win(buf, true, float_win_btm_opts())
	else
		vim.api.nvim_win_set_buf(M.window_id, buf)
	end

	M.last_win_btm_buf = buf
end
---
--- Shows `buf` in the shared floating window, creating the window if needed.
--- @param buf integer|nil
M.show_in_float_win_top = function(buf)
	if buf == nil then
		vim.notify("No buffer provided to show in floating window.", vim.log.levels.WARN)
		return
	end

	vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

	M.previous_window_id = vim.api.nvim_get_current_win()

	if M.window_top_id == nil or not vim.api.nvim_win_is_valid(M.window_top_id) then
		M.window_top_id = vim.api.nvim_open_win(buf, true, float_win_top_opts())
	else
		vim.api.nvim_win_set_buf(M.window_top_id, buf)
	end

	M.last_win_top_buf = buf
end

M.close_window = function()
	if M.window_id and vim.api.nvim_win_is_valid(M.window_id) then
		vim.api.nvim_win_close(M.window_id, false)
		M.window_id = nil
	else
		vim.notify("No valid floating window to close.", vim.log.levels.WARN)
	end
end

M.close_window_top = function()
	if M.window_top_id and vim.api.nvim_win_is_valid(M.window_top_id) then
		vim.api.nvim_win_close(M.window_top_id, false)
		M.window_id_scratch = nil
	else
		vim.notify("No valid floating window to close.", vim.log.levels.WARN)
	end
end

--- Closes the floating window if it is currently showing `expected_buf`.
--- @return boolean closed true if the window was showing expected_buf and got closed
M.toggle_float_btm = function()
	if M.window_id and vim.api.nvim_win_is_valid(M.window_id) then
		vim.api.nvim_win_close(M.window_id, false)
		M.window_id = nil
		return true
	else
		M.show_in_float(M.last_win_btm_buf)
		return false
	end
end

--- Closes the floating window if it is currently showing `expected_buf`.
--- @return boolean closed true if the window was showing expected_buf and got closed
M.toggle_float_top = function()
	if M.window_top_id and vim.api.nvim_win_is_valid(M.window_top_id) then
		vim.api.nvim_win_close(M.window_top_id, false)
		M.window_top_id = nil
		return true
	else
		M.show_in_float_win_top(M.last_win_top_buf)
		return false
	end
end


--- Closes the floating window if it is currently showing `expected_buf`.
--- @param expected_buf integer
--- @return boolean closed true if the window was showing expected_buf and got closed
M.close_float_if_showing = function(expected_buf)
	if M.window_id and vim.api.nvim_win_is_valid(M.window_id) then
		if vim.api.nvim_win_get_buf(M.window_id) == expected_buf then
			vim.api.nvim_win_close(M.window_id, false)
			M.window_id = nil
			return true
		end
		return false
	end

	if M.window_id then
		-- window_id was set but no longer refers to a valid window
		M.window_id = nil
	end
	return false
end

--- Closes the floating window if it is currently showing `expected_buf`.
--- @param expected_buf integer
--- @return boolean closed true if the window was showing expected_buf and got closed
M.close_float_top_if_showing = function(expected_buf)
	if M.window_top_id and vim.api.nvim_win_is_valid(M.window_top_id) then
		if vim.api.nvim_win_get_buf(M.window_top_id) == expected_buf then
			vim.api.nvim_win_close(M.window_top_id, false)
			M.window_top_id = nil
			return true
		end
		return false
	end

	if M.window_top_id then
		-- window_id was set but no longer refers to a valid window
		M.window_top_id = nil
	end
	return false
end


return M
