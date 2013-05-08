ActiveRecord::Base.transaction do
  english_common_dict = CommonDictionary.create!()
  english = Language.create!(name: 'english', 
    common_dictionary_id: english_common_dict.id)
  dict = []
  file = "#{Rails.root}/app/assets/dictionaries/eng_2of12.txt"
  File.foreach(file) do |line| 
    dict << line
  end
end
