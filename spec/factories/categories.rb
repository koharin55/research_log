# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  color      :string(255)
#  icon       :string(255)
#  name       :string(255)      not null
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_categories_on_user_id           (user_id)
#  index_categories_on_user_id_and_name  (user_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :category do
    
  end
end
