local config = require("config")
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
	return {render = "newpost"}
end

return handler