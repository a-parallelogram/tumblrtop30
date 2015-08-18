class BlogJob < ProgressJob::Base 

	def initialize(id, post_type, search_query, show_reblogs, numberOfPosts)
		super progress_max: 100
		@id = id
		@post_type = post_type
		@search_query = search_query
		@show_reblogs = show_reblogs
		@numberOfPosts = numberOfPosts
	end

	def perform 
		
		# Create new client to make requests to Tumblr API
    	myClient = Tumblr::Client.new
    	posts = Array.new
	    i = 0
	    blog = Blog.find(@id)
	    update_stage ("Searching " + 0.to_s + "/" + @numberOfPosts.to_s + " blog posts...")
	    steps = (@numberOfPosts/50.00)
	    base = 100.00/steps
    	until i > @numberOfPosts
    		#Increment by 20 bc need to increase offset for request. only 20 posts returned at a time.
    		if (@post_type == "all")
    			posts += (myClient.posts(@search_query, "reblog_info" => !@show_reblogs, "offset" => i ))["posts"]
	    	else
	    	#Don't need reblog info (used to remove reblogs from array) if the user wants to see reblogs.
	    		posts += (myClient.posts(@search_query, :type => @post_type, "reblog_info" => !@show_reblogs, "offset" => i ) )["posts"]
	    	end
	    	update_progress(step: base)
	    	i = i + 50
	    	update_stage ("Searching " + i.to_s + "/" + @numberOfPosts.to_s + " blog posts...")
    	end
   		
		#Ignore reblogs if user doesn't want reblogs
		if !@show_reblogs
			posts = posts.select {|x| x["reblogged_from_id"] == nil}
		end

		#Don't include posts that don't have note_count, or else error will be raised
		#Sort by descending note count, and return first 30
		blog.update(posts: posts.delete_if {|x| x["note_count"].nil? }.sort_by {|x| x["note_count"] }.reverse![0,30])

		update_progress_max(100)
	end

	def max_run_time
		400
	end

	def max_attempts
		1
	end
end
