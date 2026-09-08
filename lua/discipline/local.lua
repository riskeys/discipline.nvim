local M = {}
local DAY_IN_SECONDS = 86400

local local_scratch_subdir = ""
local local_reminder_subdir = ""
local local_daily_subdir = "/daily"
local notes_path = "notes/main.md"

local local_scratch_dir = vim.fn.expand("$HOME") .. "/scratch"

--- @param subdir string
M.set_local_scratch_subdir = function(subdir)
	local_scratch_subdir = subdir
end

--- @param subdir string
M.set_local_reminder_subdir = function(subdir)
	local_reminder_subdir = subdir
end

--- @param subdir string
M.set_local_daily_subdir = function(subdir)
	local_daily_subdir = subdir
end

local function get_scratch_daily_path()
	local today = os.date("%Y-%m-%d")
	return local_scratch_dir .. local_daily_subdir .. "/scratch_" .. today .. ".md"
end

local function get_scratch_daily_yesterday_path()
	local target_date = os.date("%Y-%m-%d", os.time() - DAY_IN_SECONDS)
	return local_scratch_dir .. local_daily_subdir .. "/scratch_" .. target_date .. ".md"
end

local function get_scratch_path()
	return local_scratch_dir .. local_scratch_subdir .. "/scratch.md"
end

local function get_reminder_path()
	return local_scratch_dir .. local_reminder_subdir .. "/reminder.md"
end

local function get_repo_notes_path()
	return notes_path
end

--- @type integer|nil
M.buf_daily = nil
--- @type integer|nil
M.buf_daily_yesterday = nil
--- @type integer|nil
M.buf_reminder = nil
--- @type integer|nil
M.buf_scratch = nil
--- @type integer|nil
M.buf_notes = nil

--- @param path string
M.set_notes_path = function(path)
	notes_path = path
end

M.get_scratch_daily_buf = function()
	if M.buf_daily == nil or not vim.api.nvim_buf_is_valid(M.buf_daily) then
		M.buf_daily = vim.fn.bufadd(get_scratch_daily_path())
	end

	return M.buf_daily
end

M.get_scratch_daily_yesterday_buf = function()
	if M.buf_daily_yesterday == nil or not vim.api.nvim_buf_is_valid(M.buf_daily_yesterday) then
		M.buf_daily_yesterday = vim.fn.bufadd(get_scratch_daily_yesterday_path())
	end

	return M.buf_daily_yesterday
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
