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
M.set_local_subdir = local_scratch.set_local_subdir

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
	toggle_btm(buf_daily)
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

local function set_keymap()
	vim.keymap.set("n", "\\n", ":CuzNotesPath ", { desc = "Set notes path" })

	vim.keymap.set("n", "\\lr", M.open_local_reminder, { desc = "Discipline: (Local) Reminder" })
	vim.keymap.set("n", "\\ls", M.open_local_scratch_top, { desc = "Discipline: (Local) Scratch" })
	vim.keymap.set("n", "\\ld", M.open_daily_local_btm, { desc = "Discipline: (Local) Scratch daily" })
	vim.keymap.set("n", "\\ll", M.open_praytell, { desc = "Discipline: Praytell" })
	vim.keymap.set("n", "\\ln", M.open_current_repo_notes, { desc = "Discipline: (Local) Repo Notes" })

	vim.keymap.set("n", "\\dr", M.open_reminder_btm, { desc = "Discipline: Reminder" })
	vim.keymap.set("n", "\\ds", M.open_scratch_top, { desc = "Discipline: Scratch" })
	vim.keymap.set("n", "\\dd", M.open_scratch_daily, { desc = "Discipline: Scratch daily" })

	vim.keymap.set("n", "\\\\b", wnd.toggle_float_btm, { desc = "Close floating window" })
	vim.keymap.set("n", "\\\\t", wnd.toggle_float_top, { desc = "Close floating window" })

	vim.keymap.set("n", "\\x", wnd.close_window, { desc = "Close floating window" })
	vim.keymap.set("n", "\\q", wnd.close_window_top, { desc = "Close floating window" })
	vim.keymap.set("n", "\\w", wnd.switch_window, { desc = "Switch window" })
	vim.keymap.set("n", "\\g", dc_scratch.open_git, { desc = "Close floating window" })
end

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


--- @param config table|nil
M.setup = function(config)
	print("setting up discipline")
	vim.api.nvim_create_user_command("CuzNotesPath", function(opts)
		M.set_repo_notes_path(opts.args)
	end, { nargs = 1, complete = "file", desc = "Set note path" })

	if config and config.local_subdir then
		local_scratch.set_local_subdir(config.local_subdir)
	end

	if config ~= nil and config.notes_path ~= nil then
		M.set_repo_notes_path(config.notes_path)
	end

	local function is_scratch_note(path)
		local scratch_dir = vim.fn.expand("$HOME/scratch")

		return vim.startswith(
			vim.fn.fnamemodify(path, ":p"),
			vim.fn.fnamemodify(scratch_dir, ":p")
		)
	end

	set_keymap()

	vim.api.nvim_create_autocmd('SwapExists', {
		callback = function(args)
			print("SwapExists autocmd triggered for file: " .. args.file)
			-- vim.v.swapchoice = "o"
			if is_scratch_note(args.file) then
				vim.v.swapchoice = "o"
			end
		end,
	})
end


return M
