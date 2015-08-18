class Blog < ActiveRecord::Base 
	serialize :posts, Array

	def get_posts (post_type, search_query, show_reblogs, numberOfPosts)
		@job = Delayed::Job.enqueue BlogJob.new(self.id, post_type, search_query, show_reblogs, numberOfPosts)
		self.update(job_id: @job.id)
	end
end
