# == Schema Information
#
# Table name: logs
#
#  id          :bigint           not null, primary key
#  body        :text(65535)
#  code        :text(65535)
#  copy_count  :integer          default(0), not null
#  pinned      :boolean          default(FALSE), not null
#  title       :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint
#  user_id     :bigint           not null
#
# Indexes
#
#  index_logs_on_category_id  (category_id)
#  index_logs_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :log do
    
  end
end
