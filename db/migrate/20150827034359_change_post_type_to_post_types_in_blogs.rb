class ChangePostTypeToPostTypesInBlogs < ActiveRecord::Migration
  def change
  	rename_column :blogs, :post_type, :post_types
  end
end
