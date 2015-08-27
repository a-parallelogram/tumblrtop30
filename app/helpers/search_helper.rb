module SearchHelper
	
	def create_post_type_checkboxes
		types = %w(photo text quote link chat audio video)
		(types.collect { |a| custom_checkbox_tag {a} } ).join
	end

	def custom_checkbox_tag
		label_tag yield, nil, class: 'checkbox-inline' do
			box = check_box_tag "post_types[]", yield,
			yield == "photo" ? true : false,
			:id => yield

			box + yield.upcase
		end
	end

end