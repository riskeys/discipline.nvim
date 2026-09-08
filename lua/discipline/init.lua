local main = require("discipline.main")
local M = vim.deepcopy(main, false)

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

local function set_keymap()
	vim.keymap.set("n", "\\n", ":CuzNotesPath ", { desc = "Set notes path" })

	vim.keymap.set("n", "\\lr", M.open_local_reminder, { desc = "Discipline: (Local) Reminder" })
	vim.keymap.set("n", "\\ls", M.open_local_scratch_top, { desc = "Discipline: (Local) Scratch" })
	vim.keymap.set("n", "\\ld", M.open_daily_local_top, { desc = "Discipline: (Local) Scratch daily" })
	vim.keymap.set("n", "\\ly", M.open_daily_local_yest_top, { desc = "Discipline: (Local) Scratch daily yest" })
	vim.keymap.set("n", "\\ll", M.open_praytell, { desc = "Discipline: Praytell" })
	vim.keymap.set("n", "\\ln", M.open_current_repo_notes, { desc = "Discipline: (Local) Repo Notes" })

	vim.keymap.set("n", "\\dr", M.open_reminder_btm, { desc = "Discipline: Reminder" })
	vim.keymap.set("n", "\\ds", M.open_scratch_top, { desc = "Discipline: Scratch" })
	vim.keymap.set("n", "\\dd", M.open_scratch_daily, { desc = "Discipline: Scratch daily" })
	vim.keymap.set("n", "\\dy", M.open_scratch_daily_yesterday, { desc = "Discipline: Scratch daily yest" })

	vim.keymap.set("n", "\\x", M.wnd_close_window, { desc = "Close floating window" })
	vim.keymap.set("n", "\\q", M.wnd_close_window_top, { desc = "Close floating window" })
	vim.keymap.set("n", "\\w", M.wnd_switch_window, { desc = "Switch window" })
	vim.keymap.set("n", "\\g", M.scratch_open_git, { desc = "Close floating window" })

	vim.keymap.set("n", "\\\\b", M.wnd_toggle_float_btm, { desc = "Close floating window" })
	vim.keymap.set("n", "\\\\t", M.wnd_toggle_float_top, { desc = "Close floating window" })
end

local function set_cmds()
	vim.api.nvim_create_user_command("Discipline", M.arg_handler,
		{ nargs = 1, complete = M.discipline_complete, desc = "Discipline" })
	vim.api.nvim_create_user_command("DC", M.arg_handler,
		{ nargs = 1, complete = M.discipline_complete, desc = "Discipline" })


	local function is_scratch_note(path)
		local scratch_dir = vim.fn.expand("$HOME/scratch")

		return vim.startswith(
			vim.fn.fnamemodify(path, ":p"),
			vim.fn.fnamemodify(scratch_dir, ":p")
		)
	end

	vim.api.nvim_create_autocmd('SwapExists', {
		callback = function(args)
			print("SwapExists autocmd triggered for file: " .. args.file)
			-- vim.v.swapchoice = "o"
			if is_scratch_note(args.file) then
				vim.v.swapchoice = "o"
			end
		end,
	})

	vim.api.nvim_create_user_command("CuzNotesPath", function(opts)
		M.set_repo_notes_path(opts.args)
	end, { nargs = 1, complete = "file", desc = "Set note path" })
end

--- @class Config
--- @field local_scratch_subdir string | nil
--- @field local_reminder_subdir string | nil
--- @field local_daily_subdir string | nil
--- @field notes_path string|nil

--- @param config Config|nil
M.setup = function(config)
	if config and config.local_scratch_subdir ~= nil then
		M.set_local_scratch_subdir(config.local_scratch_subdir)
	end
	if config and config.local_reminder_subdir ~= nil then
		M.set_local_reminder_subdir(config.local_reminder_subdir)
	end
	if config and config.local_daily_subdir ~= nil then
		M.set_local_daily_subdir(config.local_daily_subdir)
	end

	if config and config.notes_path ~= nil and type(config.notes_path) == "string" then
		M.set_repo_notes_path(config.notes_path)
	end

	set_keymap()
	set_cmds()
end


return M
