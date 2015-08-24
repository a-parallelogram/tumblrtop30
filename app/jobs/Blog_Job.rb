class BlogJob < ProgressJob::Base 

	def initialize(id, numberOfPosts)
		super progress_max: numberOfPosts
		@id = id
		@numberOfPosts = numberOfPosts
	end

	def perform 
		#initialize blog variables
		blog = Blog.find(@id)
	    search_query = blog.name
	    show_reblogs = blog.reblogs
	    post_type = blog.post_type

		# Create new client to make requests to Tumblr API
    	myClient = Tumblr::Client.new
    	
	    
	    update_stage ("Searching " + 0.to_s + "/" + @numberOfPosts.to_s + " blog posts...")

	    #final post array
	    posts = Array.new

	    #temp variables for loop
	    i = 0
	    temp_posts = Array.new
    	loop do
    		if (@post_type == "all")
    			temp_posts = (myClient.posts(search_query, "reblog_info" => !show_reblogs, "offset" => i ))["posts"]

	    	else
	    		temp_posts = (myClient.posts(search_query, :type => post_type, "reblog_info" => !show_reblogs, "offset" => i ) )["posts"]
	    	end

	    	#Increment by 50 bc need to increase offset for request. only 20 posts returned at a time.
	    	i = i + 20
	    	update_progress(step: temp_posts.length)
	    	update_stage (posts.length.to_s + "/" + @numberOfPosts.to_s + " blog posts processed")
	    	
	    	#add the fetched posts to the final post array, break if no posts were received
	    	break if temp_posts.blank?
	    	posts += temp_posts
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
		600
	end

	def max_attempts
		1
	end
end
