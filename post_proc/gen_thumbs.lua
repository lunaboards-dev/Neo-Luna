local function exists(path)
	return os.execute(string.format("stat %s 1>/dev/null 2>&1", path))
end

local function proc(post)
	if (post.img) then
		post.thumb = "thumbs/"..post.img
		if (not exists(post.thumb) and not post.thumb:match("%.webm$") and not post.thumb:match("%.gif$")) then
			os.execute("convert img/"..post.img.." -resize \"500>\" "..post.thumb)
		elseif (post.thumb:match("%.gif")) then
			post.thumb = "img/"..post.img
		end
	end
end
return proc