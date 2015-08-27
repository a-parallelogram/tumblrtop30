class Query
  include ActiveAttr::Model
  attr_accessor :query, :structure, :blog_url, :api_url, :post_types, :number_of_posts, :show_reblogs
  validates :structure, :inclusion => { :in => %w{standard custom}, :message => "Only normal and custom URI structures are allowed" }
  validates :query, presence: { :message => "Search field is empty"}
  validate :validate_post_types

  def validate_post_types
    if !post_types.is_a?(Array) || post_types.detect{ |a| !AVAILABLE_TYPES.include?(a) }
      errors.add(:post_types, "You must select a post type")
    end
  end

  #Returns true if blog url leads to a valid blog, otherwise returns false
  #Check if query is valid before executing this method
  def does_blog_exist?
    query.downcase!
    structure.downcase!
    if structure == "standard"
      self.query = query + ".tumblr.com"
    elsif structure == "custom"
      self.query = "http://" + query
      #Must check if uri is valid before calling the format uri method
      if is_uri_valid? query
        self.query = format_uri (query)
      else
        errors.add(:query, "Invalid URL")
        return false
      end
    end

    self.api_url = "http://api.tumblr.com/v2/blog/#{query}/info"
    if is_uri_valid? api_url
      myClient = Tumblr::Client.new
      response = myClient.get(api_url)

      #If blog is found, then "blog" key will be present
      if response["blog"].present?
        self.number_of_posts = response["blog"]["posts"]
        return true
      else
        errors.add(:query, "Blog could not be found")
        return false
      end
    else
      errors.add(:query, "Invalid blog name")
      return false
    end
    
  end

  private
    #Returns a blog link that is compatible with the Tumblr API.
    #must call is_uri_valid? on the uri prior to calling this method
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