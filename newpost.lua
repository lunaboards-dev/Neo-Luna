local config = require("config")
local utf8 = require("lua-utf8")
local db = require("lapis.db")
local util = require("lapis.util")
local gen_id = require("utils").genid
local get_post_id = require("utils").get_post_id
local function handler(req)
	if req.params.file and not req.params.file.content then
		return
	end
	if not config.boards[req.params.board] then
		return
	end
	local name
	if (req.params.file and #req.params.file.content > 0) then
		local tname = os.tmpname()
		local f = io.open(tname, "w")
		f:write(req.params.file.content)
		f:close()
		local h = io.popen("file -b --mime-type "..tname, "r")
		local ftype = h:read("*a"):gsub("[\r\n]+", "")
		h:close()
		if (not ftype:match("^image/") and not ftype:match("^video/webm")) then
			os.remove(tname)
			return
		end
		name = require("md5").sumhexa(req.params.file.content).."."..ftype:match("/(.+)$")
		os.execute("cp "..tname.." "..config.general.imgdir.."/"..name)
		os.remove(tname)
	end
	local id = gen_id(req.params.board)
	db.insert("threads", {
		name = utf8.sub(req.params.title, 1, 40),
		board = req.params.board,
		date = db.format_date(),
		sticky = 0,
		op = req.real_ip,
		id = id
	})
	db.insert("luna_posts", {
		id = id,
		name = req.session.current_user,
		post = utf8.sub(req.params.content, 1, 4000),
		ip = req.real_ip,
		date = db.format_date(),
		img = name,
		board = req.params.board,
		pid = get_post_id()
	})
	return {
		redirect_to = req:build_url("/"..req.params.board.."/"..string.format("%x", id), {
			status = 301
		})
    }
end

return handler