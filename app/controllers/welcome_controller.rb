class WelcomeController < ApplicationController
	
	def index
		
		@search_query = params[:search]
		@uri_structure = params[:structure]
		@post_type = params[:type]

		if (params[:reblogs] == "1")
			show_reblogs = true
		else
			show_reblogs = false
		end
		
			#check if the user has provided a URL
			q = Query.new(query: params[:search], structure: params[:structure], post_type: params[:type], show_reblogs: show_reblogs)
			if q.valid?
				blog = Blog.create(name: @search_query, post_type: @post_type, reblogs: @show_reblogs)
				puts q.number_of_posts
				blog.get_posts(q.number_of_posts)
				redirect_to waiting_blog_path(blog)
				return
			else
				error_message = ""
				q.errors.each do |attr, msg|
					error_message += msg
				end
				flash.now[:danger] = error_message
			end
	end

	private

		
end
