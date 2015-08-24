class Blog < ActiveRecord::Base 
	serialize :posts, Array

	def get_posts (numberOfPosts)
		@job = Delayed::Job.enqueue BlogJob.new(self.id, numberOfPosts)
		self.update(job_id: @job.id)
	end
end
