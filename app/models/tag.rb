class Tag < ApplicationRecord
  has_many :log_tags, dependent: :destroy
  has_many :logs, through: :log_tags

  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { case_sensitive: false }
end