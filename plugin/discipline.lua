-- print("calling discipline setup")
local dc = require("discipline")


local function set_keymap()
	vim.keymap.set("n", "\\n", ":CuzNotesPath ", { desc = "Set notes path" })

	vim.keymap.set("n", "\\lr", dc.open_local_reminder, { desc = "Discipline: (Local) Reminder" })
	vim.keymap.set("n", "\\ls", dc.open_local_scratch_top, { desc = "Discipline: (Local) Scratch" })
	vim.keymap.set("n", "\\ld", dc.open_daily_local_btm, { desc = "Discipline: (Local) Scratch daily" })
	vim.keymap.set("n", "\\ll", dc.open_praytell, { desc = "Discipline: Praytell" })
	vim.keymap.set("n", "\\ln", dc.open_current_repo_notes, { desc = "Discipline: (Local) Repo Notes" })

	vim.keymap.set("n", "\\dr", dc.open_reminder_btm, { desc = "Discipline: Reminder" })
	vim.keymap.set("n", "\\ds", dc.open_scratch_top, { desc = "Discipline: Scratch" })
	vim.keymap.set("n", "\\dd", dc.open_scratch_daily, { desc = "Discipline: Scratch daily" })

	vim.keymap.set("n", "\\\\b", dc.wnd_toggle_float_btm, { desc = "Close floating window" })
	vim.keymap.set("n", "\\\\t", dc.wnd_toggle_float_top, { desc = "Close floating window" })

	vim.keymap.set("n", "\\x", dc.wnd_close_window, { desc = "Close floating window" })
	vim.keymap.set("n", "\\q", dc.wnd_close_window_top, { desc = "Close floating window" })
	vim.keymap.set("n", "\\w", dc.wnd_switch_window, { desc = "Switch window" })
	vim.keymap.set("n", "\\g", dc.dc_scratch_open_git, { desc = "Close floating window" })
end

local opts = {
	local_subdir = "/personal"
}

vim.api.nvim_create_user_command("Discipline", dc.arg_handler,
	{ nargs = 1, complete = dc.discipline_complete, desc = "Discipline" })
vim.api.nvim_create_user_command("DC", dc.arg_handler,
	{ nargs = 1, complete = dc.discipline_complete, desc = "Discipline" })

dc.setup(opts)
set_keymap()
