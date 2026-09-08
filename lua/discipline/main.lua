local dc_scratch = require("discipline.scratch")
local local_scratch = require("discipline.local_scratch")
local wnd = require("discipline.window")
local praytell = require("discipline.praytell")


local function toggle_top(buf)
	if not wnd.close_float_top_if_showing(buf) then
		wnd.show_in_float_win_top(buf)
	end
end

local function toggle_btm(buf)
	if not wnd.close_float_if_showing(buf) then
		wnd.show_in_float(buf)
	end
end

local M = {}

M.set_repo_notes_path = local_scratch.set_notes_path
M.set_local_scratch_subdir = local_scratch.set_local_scratch_subdir
M.set_local_reminder_subdir = local_scratch.set_local_reminder_subdir
M.set_local_daily_subdir = local_scratch.set_local_daily_subdir

M.open_reminder_top = function()
	local buf_reminder = dc_scratch.get_reminder_buf()
	toggle_top(buf_reminder)
end

M.open_reminder_btm = function()
	local buf_reminder = dc_scratch.get_reminder_buf()
	toggle_btm(buf_reminder)
end

M.open_daily_btm = function()
	local buf_daily = dc_scratch.get_scratch_daily_buf()
	toggle_btm(buf_daily)
end

M.open_daily_local_btm = function()
	local buf_daily = local_scratch.get_scratch_daily_buf()
	toggle_top(buf_daily)
end

M.open_daily_local_top = function()
	local buf_daily = local_scratch.get_scratch_daily_buf()
	toggle_top(buf_daily)
end

M.open_random_buffer_test = function()
	wnd.show_in_float(0)
	wnd.show_in_float_win_top(0)
end

M.open_scratch_btm = function()
	local buf = dc_scratch.get_scratch_buf()
	toggle_btm(buf)
end

M.open_scratch_top = function()
	local buf = dc_scratch.get_scratch_buf()
	toggle_top(buf)
end

M.open_scratch_daily = function()
	local buf = dc_scratch.get_scratch_daily_buf()
	toggle_top(buf)
end

M.open_praytell = function()
	local buf_praytell = praytell.get_buf()
	toggle_btm(buf_praytell)
end

M.open_local_reminder = function()
	local buf_reminder = local_scratch.get_reminder_buf()
	toggle_btm(buf_reminder)
end

M.open_local_scratch_top = function()
	local buf_scratch = local_scratch.get_scratch_buf()
	toggle_top(buf_scratch)
end

M.open_current_repo_notes = function()
	local buf = local_scratch.get_notes_buf()
	toggle_top(buf)
end

M.wnd_toggle_float_btm = wnd.toggle_float_btm
M.wnd_toggle_float_top = wnd.toggle_float_top
M.wnd_close_window = wnd.close_window
M.wnd_close_window_top = wnd.close_window_top
M.scratch_open_git = dc_scratch.open_git
M.wnd_switch_window = wnd.switch_window

M.arg_handler = function(opts)
	if not opts.args or opts.args == "" then
		vim.notify("Argument required!", vim.log.levels.WARN)
		return
	end

	if opts.args == "scratch_daily" then
		M.open_daily_btm()
		return
	end

	if opts.args == "local_scratch_daily" then
		M.open_daily_local_top()
		return
	end

	if opts.args == "local_scratch" then
		M.open_local_scratch_top()
		return
	end

	if opts.args == "scratch" then
		M.open_scratch_top()
		return
	end

	if opts.args == "scratch_btm" then
		M.open_scratch_btm()
		return
	end

	if opts.args == "reminder" then
		M.open_reminder_btm()
		return
	end

	if opts.args == "praytell" then
		M.open_praytell()
		return
	end

	if opts.args == "local_reminder" then
		M.open_local_reminder()
		return
	end

	if opts.args == "git" then
		dc_scratch.open_git()
		return
	end

	if opts.args == "repo_notes" then
		M.open_current_repo_notes()
		return
	end

	vim.notify("Command unknown!", vim.log.levels.WARN)
end


M.discipline_complete = function(arg_lead, cmd_line, cursor_pos)
	local commands = {
		"git",
		"local_reminder",
		"local_scratch",
		"local_scratch_daily",
		"scratch_daily",
		"scratch",
		"scratch_btm",
		"reminder",
		"praytell",
		"repo_notes",
	}
	local matches = {}
	for _, cmd in ipairs(commands) do
		if vim.startswith(cmd, arg_lead) then
			table.insert(matches, cmd)
		end
	end
	return matches
end

return M
