class WelcomeController < ApplicationController
	def index
		@finalArray = Array.new
		
		if !params[:search].blank?

			#Clear http from url link bc API doesn't accept it
			query = params[:search].sub(/^https?\:\/\//, '').sub(/^www./,'')

			# Keys given from Tumblr API
		    @key = ENV["key"]
		    @secret = ENV["secret"]
		    @oauth_token = ENV["oauth_token"]
		    @oauth_token_secret = ENV["oauth_token_secret"]

		    # Sets the client that allows interfacing with Tumblr
		    @myClient = Tumblr::Client.new(
		      :consumer_key => @key,
		      :consumer_secret => @secret,
		      :oauth_token => @oauth_token,
		      :oauth_token_secret => @oauth_token_secret
		    )

		    @posts = @myClient.posts(query, :type => "photo")

		    #Get only posts array
			@posts = @posts["posts"]
			
			if !@posts.blank?
				@finalArray = @posts.sort_by {|x| x["note_count"]}.reverse![0,30]
			end
		end

	    respond_to do |format|
	      format.html # index.html.erb
	      format.json { render json: @finalArray }
	    end
	end
end
