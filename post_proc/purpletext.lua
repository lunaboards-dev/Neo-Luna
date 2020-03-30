local function proc(post)
	local pdat = post.post
	local nt = ""
	local r = false
	local open = false
	local i = 1
	local win = true
	while i <= #pdat do
		if (pdat:sub(i, i+3) == "&gt;") then
			--Count how many
			local count = 1
			--print("COUNT\n", table.concat({count, pdat:sub(i+(count*4), i+(((count+1)*4)-1)), i+(count*4), i+((count*4)-1)}, "   "), "\n")
			while pdat:sub(i+(count*4), i+(((count+1)*4)-1)) == "&gt;" do
				count = count + 1
			end
			if (count ~= 2) then
				nt = nt .. "<span style=\"color: #7700FF\">"..string.rep("&\1gt;", count)
			else
				nt = nt .. "&gt;&gt;"
			end
			i = i + (count*4)-1
			open = true
		elseif (pdat:sub(i,i) == "\n") then
			if (open) then nt = nt .. "</span>";open = false end
			r = false
			nt = nt .. "\n"
		elseif (pdat:sub(i,i) == "\r" and r) then
			if (open) then nt = nt .. "</span>";open = false end
			r = false
			nt = nt .. "\n\n"
		elseif (pdat:sub(i,i) == "\r") then
			if (open) then nt = nt .. "</span>";open = false end
			r = true
		elseif (r) then
			nt = nt .. "\n" .. pdat:sub(i,i)
		else
			nt = nt .. pdat:sub(i,i)
		end
		i = i + 1
	end
	if (open) then
		nt = nt .. "</span>"
	end
	post.post = nt
end
return proc