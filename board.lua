local config = require("config")
local db = require("lapis.db")
local bit = require("bit")
local function handler(req)
	local boards = config.boards
	for i=1, #config.general.board_listing do
		boards[i] = config.general.board_listing[i]
	end
	if (not boards[req.params.board]) then
		print("error, can't find board "..req.params.board)
		return 404
	end
	req.boards = boards
	req.board = req.params.board
	req.threads = db.select("* FROM threads WHERE board=? ORDER BY date DESC", req.board)
	table.sort(req.threads, function(a, b)
		if not (a.locked) then
			a.locked = (bit.band(a.sticky, 0x100) > 0)
			a.stickyval = bit.band(a.sticky, 0xFF)
			a.tv = os.time({
				year=tonumber(a.date:sub(1, 4)),
				month=tonumber(a.date:sub(6, 7)),
				day=tonumber(a.date:sub(9, 10)),
				hour=tonumber(a.date:sub(12, 13)),
				minute=tonumber(a.date:sub(15, 16)),
				second=tonumber(a.date:sub(18, 19)),
			})
		end
		if not (b.locked) then
			b.locked = (bit.band(b.sticky, 0x100) > 0)
			b.stickyval = bit.band(b.sticky, 0xFF)
			b.tv = os.time({
				year=tonumber(b.date:sub(1, 4)),
				month=tonumber(b.date:sub(6, 7)),
				day=tonumber(b.date:sub(9, 10)),
				hour=tonumber(b.date:sub(12, 13)),
				minute=tonumber(b.date:sub(15, 16)),
				second=tonumber(b.date:sub(18, 19)),
			})
		end

		if (a.stickyval == b.stickyval) then
			return a.tv > b.tv
		end
		
		return a.stickyval > b.stickyval
	end)
	if (#req.threads == 1) then
		req.threads[1].locked = (bit.band(req.threads[1].sticky, 0x100) > 0)
		req.threads[1].stickyval = bit.band(req.threads[1].sticky, 0xFF)
	end
	return {render = "board"}
end

return handler