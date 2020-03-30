local config = require("config")
local db = require("lapis.db")
local util = require("lapis.util")
local gen_id = require("utils").genid
local get_post_id = require("utils").get_post_id
local is_locked = require("utils").is_locked
local function handler(req)
	if req.params.file and not req.params.file.content then
		return
	end
	if not config.boards[req.params.board] then
		return
	end
	if (#db.select("id FROM threads WHERE id=? AND board=?", tonumber(req.params.id, 16), req.params.board) < 1) then
		return
	end
	if (is_locked(req.params.board, tonumber(req.params.id, 16))) then
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
	local id = tonumber(req.params.id, 16)
	db.insert("luna_posts", {
		id = id,
		name = req.session.current_user,
		post = req.params.content:sub(1, 4000),
		ip = req.real_ip,
		date = db.format_date(),
		img = name,
		board = req.params.board,
		pid = get_post_id()
	})
	db.update("threads", {
		date = db.format_date()
	}, "board=? AND id=?", req.params.board, id)
	return {
		redirect_to = req:build_url("/"..req.params.board.."/"..req.params.id, {
			status = 301
		})
    }
end

return handler