local admutil = {}
local db = require("lapis.db")
local bit = require("bit")

function admutil.delete_post(pid)
	db.delete("luna_posts", {pid=pid})
end

function admutil.delete_thread(board, id)
	db.delete("luna_posts", {id=id,board=board})
	db.delete("threads", {id=id,board=board})
end

function admutil.ip_ban(ip)
	db.insert("ipbans", {ip=ip})
end

function admutil.toggle_lock(board, id)
	local sticky = db.select("sticky FROM threads WHERE board=? AND id=?", board, id)[1].sticky
	local _l = bit.band(sticky, 0x100)
	local _s = bit.band(sticky, 0xFEFF)
	if (_l ~= 0) then
		_l = 0
	else
		_l = 0x100
	end
	db.update("threads", {
		sticky = bit.bor(_l, _s)
	}, "board=? AND id=?", board, tonumber(id))
end

function admutil.set_lock(board, id, lck)
	local sticky = db.select("sticky FROM threads WHERE board=? AND id=?", board, id)[1].sticky
	local _l = bit.band(sticky, 0x100)
	local _s = bit.band(sticky, 0xFEFF)
	_l = lck and 0x100 or 0
	db.update("threads", {
		sticky = bit.bor(_l, _s)
	}, "board=? AND id=?", board, tonumber(id))
end

function admutil.set_sticky(board, id, stk)
	local sticky = db.select("sticky FROM threads WHERE board=? AND id=?", board, id)[1].sticky
	local _s = bit.band(sticky, 0xFF00)
	db.update("threads", {
		sticky = bit.bor(_s, bit.band(stk, 0xFF))
	}, "board=? AND id=?", board, tonumber(id))
end

function admutil.toggle_gc_ignore(board, id)
	local sticky = db.select("sticky FROM threads WHERE board=? AND id=?", board, id)[1].sticky
	local _l = bit.band(sticky, 0x200)
	local _s = bit.band(sticky, 0xFDFF)
	if (_l ~= 0) then
		_l = 0
	else
		_l = 0x200
	end
	db.update("threads", {
		sticky = bit.bor(_l, _s)
	}, "board=? AND id=?", board, tonumber(id))
end

function admutil.toggle_rules_thread(board, id)
	local sticky = db.select("sticky FROM threads WHERE board=? AND id=?", board, id)[1].sticky
	local _l = bit.band(sticky, 0x400)
	local _s = bit.band(sticky, 0xFBFF)
	if (_l ~= 0) then
		_l = 0
	else
		_l = 0x400
	end
	db.update("threads", {
		sticky = bit.bor(_l, _s)
	}, "board=? AND id=?", board, tonumber(id))
end

return admutil