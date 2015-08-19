require "Blog_Job.rb"

Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 10.minutes