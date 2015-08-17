class Blog < ActiveRecord::Base
	serialize :posts, Array

	def get_posts (post_type, search_query, show_reblogs, numberOfPosts)
		# Create new client to make requests to Tumblr API
    	myClient = Tumblr::Client.new

    	posts = Array.new
	    i = 0
	    
    	until i > numberOfPosts
    		#Increment by 20 bc need to increase offset for request. only 20 posts returned at a time.
    		if (@post_type == "all")
    			posts += (myClient.posts(search_query, "reblog_info" => !show_reblogs, "offset" => i ))["posts"]
	    	else
	    	#Don't need reblog info (used to remove reblogs from array) if the user wants to see reblogs.
	    		posts += (myClient.posts(search_query, :type => post_type, "reblog_info" => !show_reblogs, "offset" => i ) )["posts"]
	    	end
	    	i = i + 20
    	end
   
		#Ignore reblogs if user doesn't want reblogs
		if !show_reblogs
			posts = posts.select {|x| x["reblogged_from_id"] == nil}
		end
		#Sort by descending note count, and return first 30
		self.posts = posts.sort_by {|x| x["note_count"]}.reverse![0,30]
		self.save
	end
end
