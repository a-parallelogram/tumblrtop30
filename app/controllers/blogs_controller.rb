class BlogsController < ApplicationController
	before_action :set_blog, only: [:show, :position_in_queue]
  def show
  end

  def position_in_queue
  	rank = Delayed::Job.all.order(id: :asc).pluck(:id).index(@blog.job_id)
  	render plain: rank
  end

  private
  def set_blog
  	@blog = Blog.find(params[:id])
  end
end
