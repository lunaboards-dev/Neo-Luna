local utils = {}
local db = require("lapis.db")
local bit = require("bit")

function utils.genid(board)
	local id = math.random(0, 2^32-1)
	while #db.select("id FROM threads WHERE id=? AND board=?", id, board) > 0 do
		id = math.random(0, 2^32-1)
	end
	return id
end

function utils.get_admin_data()
	local dat = db.select("* FROM users")
	for i=1, #dat do
		dat[dat[i].uuid] = dat[i]
	end
	return dat
end

function utils.get_post_id()
	print(require("lapis.util").to_json(db.query("SELECT MAX(pid) FROM luna_posts")))
	return (db.query("SELECT MAX(pid) FROM luna_posts")[1].max or -1)+1
end

function utils.get_token()
	local str = ""
	for i=1, 32 do
		str = str .. string.format("%.2x", math.random(0, 255))
	end
	return str
end

function utils.invalidate_tokens(uuid)
	db.query("UPDATE users SET token='', lasttoken='' WHERE \"uuid\"=?", uuid)
end

function utils.update_tokens(uuid, token)
	db.query("UPDATE users SET lasttoken=\"token\", token=? WHERE \"uuid\"=?", token, uuid)
end

function utils.verify_token(req)
	if req.session.current_user then
		local query = db.select("* FROM users WHERE uuid=?", req.session.current_user)
		if #query < 1 then
			req.session.current_user = nil
			req.session.token = nil
			return
		end
		if (req.session.token == query[1].lasttoken) then
			req.session.token = query[1].token
		end
		if (req.session.token ~= query[1].token) then
			req.session.current_user = nil
			req.session.token = nil
		else
			req.authed = true
		end
	end
end

function utils.ip_check(req)
	req.real_ip = req.req.headers["X-Real-IP"] or req.req.remote_addr
	if (#db.select("* FROM ipbans WHERE ip=?", req.real_ip) > 0) then
		error("go away")
	end
end

--The seven high bits of the sticky value are special
function utils.is_locked(board, id)
	local q = db.select("sticky FROM threads WHERE board=? AND id=?", board, id)[1]
	local locked = bit.band(q.sticky, 0x100)
	return locked > 0
end

function utils.get_sticky(board, id)
	local q = db.select("sticky FROM threads WHERE board=? AND id=?", board, id)[1]
	return bit.band(q.sticky, 0xFF)
end

return utils