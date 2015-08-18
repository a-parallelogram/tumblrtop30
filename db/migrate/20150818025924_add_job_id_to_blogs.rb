class AddJobIdToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :job_id, :integer
  end
end
