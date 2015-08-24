class WelcomeController < ApplicationController
	AVAILABLE_TYPES = %w(photo text quote link chat audio video all)
	
	def index
		@search_query = params[:search]
		@uri_structure = params[:structure]
		@post_type = params[:type]

		if (params[:reblogs] == "1")
			@show_reblogs = true
		else
			@show_reblogs = false
		end
		
		#check if the user has provided a URL
		if @search_query.present? && @uri_structure.present? && AVAILABLE_TYPES.include?(@post_type)
			if blog_is_valid?
				blog = Blog.create(name: @search_query, post_type: @post_type, reblogs: @show_reblogs)
				blog.get_posts(@numberOfPosts)
				redirect_to waiting_path(blog)
				return
			end
		end
	end

	private
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

	def blog_is_valid?
		@search_query.downcase!
		@uri_structure.downcase!

		if @uri_structure == "standard"
			@search_query = @search_query + ".tumblr.com"
			@api_url = "http://api.tumblr.com/v2/blog/#{@search_query}/info"

			if is_uri_valid? (@api_url)
				myClient = Tumblr::Client.new

			    response = myClient.get(@api_url)

			    #If blog is found, then "blog" key will be present
			    if response["blog"].present?
			    	@numberOfPosts = response["blog"]["posts"]
					return true
				else
					flash.now[:danger] = "Blog could not be found"
				end
			else
				flash.now[:danger] = "Invalid blog name"
			end
		elsif @uri_structure == "custom"
			@search_query = "http://" + @search_query
			if is_uri_valid? (@search_query)
				@search_query = format_uri (@search_query)
				@api_url = "http://api.tumblr.com/v2/blog/#{@search_query}/info"

				myClient = Tumblr::Client.new

			    response = myClient.get(@api_url)

			    #If blog is found, then "blog" key will be present
			    if response["blog"].present?
			    	@numberOfPosts = response["blog"]["posts"]
					return true
				else
					flash.now[:danger] = "Blog could not be found"
				end
			else
				flash.now[:danger] = "Invalid URL"
			end
		end
		return false
	end
end
