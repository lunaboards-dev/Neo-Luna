local db = require("lapis.db")
local function proc(post)
	local pdat = post.post
	local nt = ""
	local i = 1
	while i <= #pdat do
		if (pdat:sub(i, i+7) == "&gt;&gt;") then
			--Read until we reach a space
			local imod = 8
			local id = ""
			while true do
				if (pdat:sub(i+imod, i+imod):match("%D") or pdat:sub(i+imod, i+imod) == "") then
					break
				else
					id = id .. pdat:sub(i+imod, i+imod)
				end
				imod = imod + 1
			end
			if (tonumber(id, 10))  then
				--nt = nt .. "<a href=./"..post.id.."#post_"..
				local postdat = db.select("* FROM luna_posts WHERE pid=?", tonumber(id, 10))
				if (#postdat > 0) then
					local text = id
					local url = ""
					local newpage = false
					if (postdat[1].id ~= post.id) then
						text = string.format("%x", postdat[1].id) .. "#" .. id
						newpage = true
						url = string.format("%x#post_%s", postdat[1].id, id)
					else
						url = "#post_"..id
					end
					if (postdat[1].board ~= post.board) then
						text = "/"..postdat[1].board .. "/" .. text
						url = "/"..postdat[1].board .. "/" .. url
					elseif (newpage) then
						url = "./" .. url
					end
					nt = nt .. "<a href="..url.." class=\"replylink\""
					if (newpage) then
						nt = nt .. " target=\"_blank\""
					end
					nt = nt .. ">&gt;&gt;"..text.."</a>"
					i = i + imod - 1
				else
					nt = nt .. "&"
				end
			else
				nt = nt .. "&"
			end
		else
			nt = nt .. pdat:sub(i, i)
		end
		i = i+1
	end
	post.post = nt
end

return proc