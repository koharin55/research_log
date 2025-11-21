class Log < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  has_many_attached :images

  has_many :log_tags, dependent: :destroy
  has_many :tags, through: :log_tags

  validates :title, presence: true, length: { maximum: 100 }

  validate :images_count_within_limit

  scope :pinned_first, -> { order(pinned: :desc, updated_at: :desc) }
  scope :most_used,    -> { order(copy_count: :desc) }

  private

  def images_count_within_limit
    if images.attachments.size > 5
      errors.add(:images, "は5枚までです")
    end
  end
end
