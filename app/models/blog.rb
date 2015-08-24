class Blog < ActiveRecord::Base 
	serialize :posts, Array

	def get_posts (post_type, show_reblogs, numberOfPosts)
		@job = Delayed::Job.enqueue BlogJob.new(self.id, post_type, show_reblogs, numberOfPosts)
		self.update(job_id: @job.id)
	end
end
