local utils = require("utils")
local config = require("config")
local db = require("lapis.db")
local md5 = require("md5")

--Post proccessing
local proc = {
	require("post_proc.get_replies"), --Doesn't actually modify text.
	require("post_proc.gen_thumbs"), --Doesn't actually modify text.
	require("post_proc.html_escape"),
	require("post_proc.purpletext"),
	require("post_proc.reply"),
	require("post_proc.breaks"),
	require("post_proc.final_pass") -- This should always be last.
}

local function proc_text(post)
	for i=1, #proc do
		proc[i](post)
	end
end

local function handler(req)
	local boards = config.boards
	for i=1, #config.general.board_listing do
		boards[i] = config.general.board_listing[i]
	end
	if (not boards[req.params.board]) then
		print("error, can't find board "..req.params.board)
		return 404
	end
	if (not tonumber(req.params.id, 16)) then
		return 404
	end
	req.admin_dat = utils.get_admin_data()
	req.hash = function(_, a)
		return md5.sumhexa(a)
	end
	local thread = db.select("* FROM threads WHERE id=? AND board=?", tonumber(req.params.id, 16), req.params.board)
	if #thread < 1 then
		return 404
	end
	req.thread = thread[1]
	req.posts = db.select("* FROM luna_posts WHERE id=? AND board=? ORDER BY pid ASC", tonumber(req.params.id, 16), req.params.board)
	for i=1, #req.posts do
		proc_text(req.posts[i])
	end
	req.boards = boards
	req.board = req.params.board
	req.thread.stickyval = utils.get_sticky(thread[1].board, thread[1].id)
	req.thread.locked = utils.is_locked(thread[1].board, thread[1].id)
	--print(req.stickyval, req.locked)
	return {render = "thread"}
end

return handler