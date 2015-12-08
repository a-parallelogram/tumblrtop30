class BlogJob < ProgressJob::Base

  #Number of threads used to send requests to API
  THREAD_COUNT = 5
  #Parameters are id of blog and total number of posts for blog
  def initialize(id, number_of_posts)
    super progress_max: number_of_posts
    @id = id
    @number_of_posts = number_of_posts
  end
  
  def perform 
    #initialize blog variables
    blog = Blog.find(@id)
    search_query = blog.name
    show_reblogs = blog.reblogs
    post_types = blog.post_types

    # Create new client to make requests to Tumblr API
    myClient = Tumblr::Client.new
    
    update_stage ("Searching blog posts...")

    #final post array
    posts = Array.new

    post_types.each do |post_type|
      counter = 0
      threads = []
      threads  = (1..THREAD_COUNT).collect do |k|
        offset = counter
        t = Thread.new{getPosts(myClient, search_query, post_type, show_reblogs, offset)}
        counter += 20
        t
      end

      threads.each do |t|
        t.join
        posts += t.value
      end
    end
    #Ignore reblogs if user doesn't want reblogs
    if !@show_reblogs
      posts = posts.select {|x| x["reblogged_from_id"] == nil}
    end

    #Don't include posts that don't have note_count (raises error when sorting), or a note_count of 0
    #Sort by descending note count, and return first 30
    blog.update(posts: posts.delete_if {|x| x["note_count"].nil? || x["note_count"] == 0 }.sort_by {|x| x["note_count"] }.reverse![0,30])

    update_progress_max(100)
  end

  def getPosts(myClient, search_query, post_type, show_reblogs, offset)
    posts = Array.new
    loop do
        temp_posts = Array.new
        temp_posts = (myClient.posts(search_query, :type => post_type, "reblog_info" => !show_reblogs, "offset" => offset ) )["posts"]
        
        #Need to increment offset by 80 for next request bc 4 threads
        offset = offset + (THREAD_COUNT * 20)
        update_progress(step: temp_posts.length)
        
        #add the fetched posts to the final post array, break if no posts were received
        break if temp_posts.blank?
        posts += temp_posts
    end
    return posts
  end

  def max_run_time
    600
  end

  def max_attempts
    1
  end
end
