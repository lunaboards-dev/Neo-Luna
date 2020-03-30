local db = require("lapis.db")
local function proc(post)
	local reply = ">>"..post.pid
	local replies = db.select("* FROM luna_posts WHERE post ~ ?", "[^>]"..reply.."[^\\d]")
	post.replies = {}
	for i=1, #replies do
		local text = ""..replies[i].pid
		local link = string.format("%x", replies[i].id) .. "#post_"..replies[i].pid
		if (replies[i].id ~= post.id) then
			text = string.format("%x", replies[i].id) .. "#" .. text
			if replies[i].board ~= post.board then
				text = "/"..replies[i].board.."/"..text
				link = "/"..replies[i].board.."/"..link
			else
				link = "./"..link
			end
		end
		post.replies[#post.replies+1] = {text, link, replies[i].pid}
	end
	replies = db.select("* FROM luna_posts WHERE post ~ ?", "^"..reply.."[^\\d]")
	for i=1, #replies do
		local text = ""..replies[i].pid
		local link = string.format("%x", replies[i].id) .. "#post_"..replies[i].pid
		if (replies[i].id ~= post.id) then
			text = string.format("%x", replies[i].id) .. "#" .. text
			if replies[i].board ~= post.board then
				text = "/"..replies[i].board.."/"..text
				link = "/"..replies[i].board.."/"..link
			else
				link = "./"..link
			end
		end
		post.replies[#post.replies+1] = {text, link, replies[i].pid}
	end
	replies = db.select("* FROM luna_posts WHERE post ~ ?", "[^>]"..reply.."$")
	for i=1, #replies do
		local text = ""..replies[i].pid
		local link = string.format("%x", replies[i].id) .. "#post_"..replies[i].pid
		if (replies[i].id ~= post.id) then
			text = string.format("%x", replies[i].id) .. "#" .. text
			if replies[i].board ~= post.board then
				text = "/"..replies[i].board.."/"..text
				link = "/"..replies[i].board.."/"..link
			else
				link = "./"..link
			end
		end
		post.replies[#post.replies+1] = {text, link, replies[i].pid}
	end
	replies = db.select("* FROM luna_posts WHERE post ~ ?", "^"..reply.."$")
	for i=1, #replies do
		local text = ""..replies[i].pid
		local link = string.format("%x", replies[i].id) .. "#post_"..replies[i].pid
		if (replies[i].id ~= post.id) then
			text = string.format("%x", replies[i].id) .. "#" .. text
			if replies[i].board ~= post.board then
				text = "/"..replies[i].board.."/"..text
				link = "/"..replies[i].board.."/"..link
			else
				link = "./"..link
			end
		end
		post.replies[#post.replies+1] = {text, link, replies[i].pid}
	end
	table.sort(post.replies, function(a, b)
		return a[3] < b[3]
	end)
end

return proc