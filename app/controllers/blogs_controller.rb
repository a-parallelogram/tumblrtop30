class BlogsController < ApplicationController
	before_action :set_blog, only: [:show, :waiting, :position_in_queue]
  def show
  end

  def position_in_queue
  	rank = Delayed::Job.all.order(id: :asc).pluck(:id).index(@blog.job_id)
  	render plain: rank
  end

  def waiting
    #In case user navigates to waiting page and job is already complete, direct them to show page
    unless @blog.posts.blank? && Delayed::Job.find_by(id: @blog.job_id) != nil
      redirect_to @blog
    end
  end

  private
  def set_blog
  	@blog = Blog.find(params[:id])
  end
end
