local config = require("config")
local db = require("lapis.db")

local function handler(req)
	local boards = config.boards
	for i=1, #config.general.board_listing do
		boards[i] = config.general.board_listing[i]
	end
	req.boards = boards
	return {render = "boards", title="Luna - Late Night Shitposting Mk2"}
end

return handler