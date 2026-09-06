local M = {}

--- @type string
M.local_subdir = "/personal"

--- @type string
M.notes_path = "notes/main.md"

--- @param subdir string
M.set_local_subdir = function(subdir)
	M.local_subdir = subdir
end

local LOCAL_SCRATCH_DIR = vim.fn.expand("$HOME") .. "/scratch"

local function get_scratch_daily_path()
	local today = os.date("%Y-%m-%d")
	return LOCAL_SCRATCH_DIR .. "/daily/scratch_" .. today .. ".md"
end

local function get_scratch_path()
	return LOCAL_SCRATCH_DIR .. M.local_subdir .. "/scratch.md"
end

local function get_reminder_path()
	return LOCAL_SCRATCH_DIR .. M.local_subdir .. "/reminder.md"
end

local function get_repo_notes_path()
	return M.notes_path
end

--- @type integer|nil
M.buf_daily = nil
--- @type integer|nil
M.buf_reminder = nil
--- @type integer|nil
M.buf_scratch = nil
--- @type integer|nil
M.buf_notes = nil

--- @param path string
M.set_notes_path = function(path)
	M.notes_path = path
end

M.get_scratch_daily_buf = function()
	if M.buf_daily == nil or not vim.api.nvim_buf_is_valid(M.buf_daily) then
		M.buf_daily = vim.fn.bufadd(get_scratch_daily_path())
	end

	return M.buf_daily
end

M.get_scratch_buf = function()
	if M.buf_scratch == nil or not vim.api.nvim_buf_is_valid(M.buf_scratch) then
		M.buf_scratch = vim.fn.bufadd(get_scratch_path())
	end

	return M.buf_scratch
end

--- @return integer
M.get_reminder_buf = function()
	if M.buf_reminder == nil or not vim.api.nvim_buf_is_valid(M.buf_reminder) then
		M.buf_reminder = vim.fn.bufadd(get_reminder_path())
	end

	return M.buf_reminder
end

--- @return integer
M.get_notes_buf = function()
	if M.buf_scratch == nil or not vim.api.nvim_buf_is_valid(M.buf_notes) then
		M.buf_notes = vim.fn.bufadd(get_repo_notes_path())
	end

	return M.buf_notes
end

return M
