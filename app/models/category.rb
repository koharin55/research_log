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
class Category < ApplicationRecord
  belongs_to :user
  has_many   :logs, dependent: :nullify

  validates :name, presence: true, length: { maximum: 50 }
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }
end
