class AddReblogsAndTypeToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :reblogs, :boolean
    add_column :blogs, :post_type, :string
  end
end
