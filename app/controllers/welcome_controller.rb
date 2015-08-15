class WelcomeController < ApplicationController
	def index
		@finalArray = Array.new
		
		@search_query = params[:search]
		@uri_structure = params[:structure]
		if (params[:reblogs] == "1")
			@show_reblogs = true
		else
			@show_reblogs = false
		end



		#check if the user has provided a URL
		if @search_query.present? && @uri_structure.present?

			@search_query.downcase!
			@uri_structure.downcase!

			input_is_valid = false 

			if @uri_structure == "standard"
				@search_query = @search_query + ".tumblr.com"
				@api_url = "http://api.tumblr.com/v2/blog/#{@search_query}/info"

				if is_uri_valid? (@api_url)
					input_is_valid = true
				else
					flash.now[:danger] = "Invalid blog name"
				end
			elsif @uri_structure == "custom"
				if is_uri_valid? (@search_query)
					@search_query = format_uri (@search_query)
					@api_url = "http://api.tumblr.com/v2/blog/#{@search_query}/info"
					input_is_valid = true
				else
					flash.now[:danger] = "Invalid URL"
				end
			end

			if input_is_valid
				get_posts 
			end
		end

	    respond_to do |format|
	      format.html # index.html.erb
	      format.json { render json: @finalArray }
	    end
	end

	def get_posts
		# Create new client to make requests to Tumblr API
    	myClient = Tumblr::Client.new

	    response = myClient.get(@api_url)

	    #If blog is found, then "blog" key will be present
	    if response["blog"].present?
	    	#Don't need reblog info (used to remove reblogs from array) if the user wants to see reblogs.
	    	@posts = myClient.posts(@search_query, :type => "photo", "reblog_info" => !@show_reblogs)

		    #Get only posts array
			@posts = @posts["posts"]

			#Ignore reblogs if user doesn't want reblogs
			if !@show_reblogs
				@posts = @posts.select {|x| x["reblogged_from_id"] == nil}
			end

			#Sort by descending note count, and return first 30
			@finalArray = @posts.sort_by {|x| x["note_count"]}.reverse![0,30]
		else
			flash.now[:danger] = "Blog could not be found"
	    end
	end

	def format_uri (uri)
		uri = URI.parse(uri)
		if(uri.scheme)
		    uri.host
		else
			uri.to_s
		end
	end

	#http://stackoverflow.com/questions/5331014/check-if-given-string-is-an-url
	def is_uri_valid?(string)
	  uri = URI.parse(string)
	  %w( http https ).include?(uri.scheme)
	rescue URI::BadURIError
	  false
	rescue URI::InvalidURIError
	  false
	end
end
