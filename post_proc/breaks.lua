local function proc(post)
	while post.post:match("\n\n\n") do
		post.post = post.post:gsub("\n\n\n", "\n\n")
	end
	post.post = post.post:gsub("\n", "<br>")
end
return proc