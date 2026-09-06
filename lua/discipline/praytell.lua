local BANDUNG_CITY_ID = "fc221309746013ac554571fbd180e1c8"
local SCHEDULE_DIR = vim.fn.expand("$HOME") .. "/praytell"

--- @param url string
--- @return string
local function http_get(url)
	local result = vim.system({ "curl", "-s", url }):wait()
	if result.code ~= 0 then
		return ""
	end
	return result.stdout or ""
end

--- @param year integer
--- @param month integer
--- @return string
local function schedule_dir(year, month)
	return string.format("%s/%d/%02d", SCHEDULE_DIR, year, month)
end

--- @param year integer
--- @param month integer
--- @param day string
--- @return string
local function schedule_file(year, month, day)
	return schedule_dir(year, month) .. "/" .. day .. ".json"
end
---
--- @param today_table osdate
local function fetch_schedules(today_table)
	local year = today_table.year
	local month = today_table.month
	local date_query = string.format("%d-%02d", year, month)
	local url = "https://api.myquran.com/v3/sholat/jadwal/" .. BANDUNG_CITY_ID .. "/" .. date_query

	local ok, json_res = pcall(vim.json.decode, http_get(url))
	if not ok or not json_res.data or not json_res.data.jadwal then
		vim.notify("Failed to fetch prayer schedule.", vim.log.levels.ERROR)
		return
	end

	vim.fn.mkdir(schedule_dir(year, month), "p")
	for day, entry in pairs(json_res.data.jadwal) do
		vim.fn.writefile({ vim.json.encode(entry) }, schedule_file(year, month, day))
	end
end
---
--- @return string[]
local function get_today_prayer_schedule()
	local today_table = os.date("*t")
	local today = os.date("%Y-%m-%d")
	local file_name = schedule_file(today_table.year, today_table.month, today)

	local ok, lines = pcall(vim.fn.readfile, file_name)
	if not ok then
		fetch_schedules(today_table)
		ok, lines = pcall(vim.fn.readfile, file_name)
	end
	if not ok then
		return { "Error: Failed to read schedule." }
	end

	local jadwal = vim.json.decode(table.concat(lines, "\n"))
	return {
		"jadwal",
		jadwal.tanggal,
		"",
		"---",
		"",
		"subuh: " .. jadwal.subuh,
		"dhuhur: " .. jadwal.dzuhur,
		"ashar: " .. jadwal.ashar,
		"maghrib: " .. jadwal.maghrib,
		"isya: " .. jadwal.isya,
	}
end

local M = {}

--- @type integer|nil
M.buf = nil

M.get_buf = function()
	if M.buf == nil or not vim.api.nvim_buf_is_valid(M.buf) then
		M.buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, get_today_prayer_schedule())
	end

	vim.api.nvim_set_option_value("modifiable", false, { buf = M.buf })
	return M.buf
end


return M
