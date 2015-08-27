class ChangePostTypeFromStringToTextInBlog < ActiveRecord::Migration
  def up
  	change_column :blogs, :post_type, :text
  end

  def down
  	change_column :blogs, :post_type, :string
  end
end
