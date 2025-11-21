class Category < ApplicationRecord
  belongs_to :user
  has_many   :logs, dependent: :nullify

  validates :name, presence: true, length: { maximum: 50 }
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }
end
