local function proc(post)
	post.post = post.post:gsub("\1", "")
end
return proc