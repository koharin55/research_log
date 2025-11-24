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
class Log < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  has_many_attached :images

  has_many :log_tags, dependent: :destroy
  has_many :tags, through: :log_tags

  validates :title, presence: true, length: { maximum: 100 }
  validates :memo,  length: { maximum: 200 }, allow_blank: true
  validate :images_count_within_limit

  # --- 並び順スコープ ---
  scope :pinned_first, -> { order(pinned: :desc, updated_at: :desc) }
  scope :most_used,    -> { order(copy_count: :desc) }

  # --- キーワード検索スコープ ---
  # params[:q] をスペース区切りで AND / OR 検索する
  #
  # 使用例:
  #   Log.keyword_search("VLOOKUP INDEX", mode: :and)
  #   Log.keyword_search("VLOOKUP INDEX", mode: :or)
  #
scope :keyword_search, ->(query, mode: :and) {
  return all if query.blank?

  terms = query.to_s.split(/[[:blank:]]+/).map(&:strip).reject(&:empty?)
  return all if terms.empty?

  table = arel_table

  case mode.to_s
  when 'or'
    # OR検索（どれかの単語がヒット）
    or_condition = terms.map do |term|
      like = "%#{term}%"
      table[:title].matches(like)
        .or(table[:memo].matches(like))
        .or(table[:code].matches(like))
    end.inject { |cond, c| cond.or(c) }

    where(or_condition)

  else
    # AND検索（すべての単語を含む）
    terms.inject(all) do |scope, term|
      like = "%#{term}%"
      condition = table[:title].matches(like)
                    .or(table[:memo].matches(like))
                    .or(table[:code].matches(like))
      scope.where(condition)
    end
  end
}

  # --- カテゴリ絞り込み ---
  #
  # params[:category_id] から呼び出す想定:
  #   Log.by_category(params[:category_id])
  #
  scope :by_category, ->(category_id) {
    return all if category_id.blank?
    where(category_id: category_id)
  }

  # --- タグ複数選択: 指定されたタグを「すべて」持つログのみ ---
  #
  # params[:tag_ids] (配列) を想定:
  #   Log.with_all_tags(params[:tag_ids])
  #
  scope :with_all_tags, ->(tag_ids) {
    ids = Array(tag_ids).reject(&:blank?)
    return all if ids.empty?

    joins(:log_tags)
      .where(log_tags: { tag_id: ids })
      .group(:id)
      .having('COUNT(DISTINCT log_tags.tag_id) = ?', ids.size)
  }

  private

  def images_count_within_limit
    if images.attachments.size > 5
      errors.add(:images, "は5枚までです")
    end
  end
end
