class QueryController < ApplicationController

  def search
    q = Query.new(query: params[:search], structure: params[:structure], post_types: params[:post_types], show_reblogs: params[:show_reblogs])
    if q.valid? && q.does_blog_exist?
      blog = Blog.create(name: q.query, post_types: q.post_types, reblogs: q.show_reblogs)
      blog.get_posts(q.number_of_posts)
      redirect_to waiting_blog_path(blog)
      return
    else
      error_message = ""
      q.errors.each do |attr, msg|
        error_message += msg + " "
      end
      flash[:danger] = error_message
      #Remember search parameters so user doesn't need to reenter them
      redirect_to :controller => 'welcome', :action => 'index', :uri_structure => params[:structure], :post_type => params[:post_type], :show_reblogs => params[:show_reblogs], :post_types => params[:post_types]
    end
  end
  
end