class BlogJob < ProgressJob::Base 

	def initialize(id, post_type, search_query, show_reblogs, numberOfPosts)
		super progress_max: numberOfPosts
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
	    temp_posts = Array.new
    	loop do
    		if (@post_type == "all")
    			temp_posts = (myClient.posts(@search_query, "reblog_info" => !@show_reblogs, "offset" => i ))["posts"]

	    	else
	    	#Don't need reblog info (used to remove reblogs from array) if the user wants to see reblogs.
	    		temp_posts = (myClient.posts(@search_query, :type => @post_type, "reblog_info" => !@show_reblogs, "offset" => i ) )["posts"]
	    	end

	    	update_progress(step: 50)
	    	#Increment by 50 bc need to increase offset for request. only 50 posts returned at a time.
	    	i = i + 50
	    	update_stage (i.to_s + "/" + @numberOfPosts.to_s + " blog posts processed")
	    	posts += temp_posts
	    	break if temp_posts.blank?
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
