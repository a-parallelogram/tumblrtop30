class Blog < ActiveRecord::Base 
  serialize :posts, Array
  serialize :post_types, Array

  #Creates a new job that retrieves the blog's posts 
  def get_posts (number_of_posts)
    @job = Delayed::Job.enqueue BlogJob.new(self.id, number_of_posts)
    self.update(job_id: @job.id)
  end
end
