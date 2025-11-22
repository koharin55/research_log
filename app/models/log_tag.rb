# == Schema Information
#
# Table name: log_tags
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  log_id     :bigint           not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_log_tags_on_log_id             (log_id)
#  index_log_tags_on_log_id_and_tag_id  (log_id,tag_id) UNIQUE
#  index_log_tags_on_tag_id             (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (log_id => logs.id)
#  fk_rails_...  (tag_id => tags.id)
#
class LogTag < ApplicationRecord
  belongs_to :log
  belongs_to :tag
end
