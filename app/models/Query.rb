class Query
	include ActiveAttr::Model
	attr_accessor :query, :structure, :blog_url, :api_url, :post_type, :number_of_posts
	validates :post_type, :inclusion => { :in => AVAILABLE_TYPES, :message => "not in types" }
	validates :query, :presence => true
	validates :structure, :presence => true
	validate :blog_is_valid?



	#Returns true if blog url leads to a valid blog, otherwise returns false
	def blog_is_valid?
		query.downcase!
		structure.downcase!
		if structure == "standard"
			self.query = query + ".tumblr.com"
			self.api_url = "http://api.tumblr.com/v2/blog/#{query}/info"
		elsif structure == "custom"
			self.query = "http://" + query
			#Must check if uri is valid before calling the format uri method
			if is_uri_valid? query
				self.query = format_uri (query)
			else
				errors.add(:query, "Invalid URL")
				return
			end
		end

		@api_url = "http://api.tumblr.com/v2/blog/#{query}/info"
		if is_uri_valid? api_url
			myClient = Tumblr::Client.new
		    response = myClient.get(api_url)

		    #If blog is found, then "blog" key will be present
		    if response["blog"].present?
		    	self.number_of_posts = response["blog"]["posts"]
				return
			else
				errors.add(:query, "Blog could not be found")
				return
			end
		else
			errors.add(:query, "Invalid blog name")
			return
		end
		
	end

	private
		#Returns a blog link that is compatible with the Tumblr API
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