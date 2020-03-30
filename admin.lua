local adm = require("admin_utils")
local utils = require("utils")
local db = require("lapis.db")
local bcrypt = require("bcrypt")
local function hand(req)
	if (not req.authed) then return nil end
	if (req.params.com == "del") then
		adm.delete_thread(req.params.board, tonumber(req.params.id, 16))
	elseif (req.params.com == "lock") then
		adm.toggle_lock(req.params.board, tonumber(req.params.id, 16))
	elseif (req.params.com == "pdel") then
		adm.delete_post(tonumber(req.params.pid))
	elseif (req.params.com == "ipban") then
		adm.ip_ban(req.params.ip)
	elseif (req.params.com == "sticky") then
		if (utils.get_sticky(req.params.board, tostring(req.params.id)) == 0) then
			adm.set_sticky(req.params.board, tostring(req.params.id), 1)
		else
			adm.set_sticky(req.params.board, tostring(req.params.id), 0)
		end
	elseif (req.params.com == "ctl") then
		req.admin_data = utils.get_admin_data()[req.session.current_user]
		return { render = "admin" }
	elseif (req.params.com == "update") then
		local uuid = req.session.current_user
		db.update("users", {
			name = req.params.name,
			color = req.params.color
		}, "uuid=?", uuid)
		return {
			redirect_to = req:build_url("/", {
				status = 307
			})
		}
	elseif (req.params.com == "passwd") then
		local uuid = req.session.current_user
		db.update("users", {
			pass = bcrypt.digest(req.params.pass, 10)
		}, "uuid=?", uuid)
		utils.invalidate_tokens(uuid)
		local tok = utils.get_token()
		utils.update_tokens(uuid, tok)
		req.session.token = tok
		return {
			redirect_to = req:build_url("/", {
				status = 307
			})
		}
	elseif (req.params.com == "thdupdate") then
		adm.set_lock(req.params.board, tostring(req.params.id), req.params.locked == "on")
		adm.set_sticky(req.params.board, tostring(req.params.id), tonumber(req.params.sticky))
	end
	return {
		redirect_to = req:build_url(req.req.headers["referer"] or "/", {
			status = 307
		})
    }
end

return hand