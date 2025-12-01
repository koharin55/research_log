# == Schema Information
#
# Table name: logs
#
#  id          :bigint           not null, primary key
#  body        :text(65535)
#  code        :text(65535)
#  copy_count  :integer          default(0), not null
#  memo        :text(65535)
#  pinned      :boolean          default(FALSE), not null
#  title       :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint           not null
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
require 'rails_helper'

RSpec.describe Log, type: :model do
  before do
    @log = FactoryBot.create(:log)
    @log.update_columns(updated_at: 5.days.ago)
  end

  describe "ログ登録" do
    context "ログ登録ができるとき" do
      it "すべての項目を入力すれば登録できる" do
        expect(@log).to be_valid
      end

      it "タイトルが100文字以内なら有効" do
        @log.title = Faker::Lorem.characters(number: 100)
        expect(@log).to be_valid
      end
    end

    context "ログ登録ができないとき" do
      it "タイトルが空だと無効" do
        @log.title = ""
        expect(@log).to be_invalid
        expect(@log.errors[:title]).to be_present
      end

      it "タイトルが101文字以上だと無効" do
        @log.title = Faker::Lorem.characters(number: 101)
        expect(@log).to be_invalid
        expect(@log.errors[:title]).to be_present
      end

      it "ユーザーが無いと無効" do
        @log.user = nil
        expect(@log).to be_invalid
        expect(@log.errors[:user]).to be_present
      end
    end
  end

  describe "スコープ" do
    let!(:user)      { create(:user) }
    let!(:category1) { create(:category, user: user) }
    let!(:category2) { create(:category, user: user) }

    let!(:log_a) do
      create(:log, user: user, category: category1, title: "Git rebase", memo: "rebase -i", code: "git rebase -i HEAD~3", copy_count: 1).tap do |log|
        log.update_columns(updated_at: 1.day.ago)
      end
    end

    let!(:log_b) do
      create(:log, user: user, category: category2, title: "Rails migrate", memo: "db:migrate", code: "rails db:migrate", copy_count: 5).tap do |log|
        log.update_columns(updated_at: 2.days.ago)
      end
    end

    let!(:log_c) do
      create(:log, user: user, category: category2, title: "Docker build", memo: "build image", code: "docker build .", copy_count: 3).tap do |log|
        log.update_columns(updated_at: 3.days.ago)
      end
    end

    let!(:tag_ruby)   { create(:tag, name: "ruby") }
    let!(:tag_docker) { create(:tag, name: "docker") }

    before do
      log_a.tags << tag_ruby
      log_b.tags << [tag_ruby, tag_docker]
      log_c.tags << tag_docker
    end

    context "キーワード検索" do
      it "AND 検索で全てのキーワードを含むログのみ返す" do
        results = Log.keyword_search("Rails migrate", mode: :and)
        expect(results).to match_array([log_b])
      end

      it "OR 検索でいずれかのキーワードを含むログを返す" do
        results = Log.keyword_search("Docker Rails", mode: :or)
        expect(results).to match_array([log_b, log_c])
      end
    end

    context "by_category" do
      it "指定したカテゴリのログだけ返す" do
        results = Log.by_category(category1.id)
        expect(results).to match_array([log_a])
      end
    end

    context "with_any_tags / with_all_tags" do
      it "with_any_tags はいずれかのタグを持つログを返す" do
        expect(Log.with_any_tags([tag_docker.id])).to match_array([log_b, log_c])
      end

      it "with_all_tags は全てのタグを持つログのみ返す" do
        expect(Log.with_all_tags([tag_ruby.id, tag_docker.id])).to match_array([log_b])
      end
    end

    context "most_used/updated_at ソート" do
      it "most_used はコピー回数の多い順" do
        expect(Log.most_used.first).to eq(log_b)
      end

      it "updated_at の降順で最新が先頭になる" do
        expect(Log.order(updated_at: :desc).first).to eq(log_a)
      end
    end
  end
end
