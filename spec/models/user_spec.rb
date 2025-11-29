# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  nickname               :string(255)      default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
  end
  
  describe "ユーザー新規登録" do
    context "ユーザー新規登録ができるとき" do
      it "nickname、email、password、password_confirmationが存在すれば登録できる" do
        expect(@user).to be_valid
      end

      it "ニックネームが30文字以内なら登録できる" do
        @user.nickname = "a" * 30
        expect(@user).to be_valid
      end

      it 'passwordが6文字以上で、半角英数字を両方含んでいれば登録できる' do
        @user.password = 'abc123'
        @user.password_confirmation = 'abc123'
        expect(@user).to be_valid
      end
    end

    context "ユーザー新規登録ができないとき" do
      it "nicknameが空では登録できない" do
        @user.nickname = ""
        @user.valid?
        expect(@user.errors.full_messages).to include("Nicknameを入力してください")
      end

      it "ニックネームが31文字以上だと登録できない" do
        @user.nickname = "a" * 31
        @user.valid?
        expect(@user.errors.full_messages).to include("Nicknameは30文字以内で入力してください")
      end

      it "メールアドレスが空だと登録できない" do
        @user.email = ""
        @user.valid?
        expect(@user.errors.full_messages).to include("Emailを入力してください")
      end

      it 'パスワードが空では登録できない' do
        @user.password = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Passwordを入力してください")
      end

      it 'パスワードとパスワード（確認）が不一致では登録できない' do
        @user.password_confirmation = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Password confirmationと一致しません")
      end

      it "重複したメールアドレスが存在すると無効" do
        @user.save
        another_user = FactoryBot.build(:user, email: @user.email)
        another_user.valid?
        expect(another_user.errors.full_messages).to include("Emailはすでに存在します")
      end

      it "パスワードが6文字未満だと無効" do
        @user.password = "abc1!"
        @user.password_confirmation = "abc1!"
        @user.valid?
        expect(@user.errors.full_messages).to include("Passwordは6文字以上で入力してください")
      end

      it 'passwordは半角英字のみでは登録できない' do
        @user.password = 'abcdef'
        @user.password_confirmation = 'abcdef'
        @user.valid?
        expect(@user.errors.full_messages).to include("Passwordは半角英数を両方含む必要があります")
      end

      it 'passwordは半角数字のみでは登録できない' do
        @user.password = '123456'
        @user.password_confirmation = '123456'
        @user.valid?
        expect(@user.errors.full_messages).to include("Passwordは半角英数を両方含む必要があります")
      end
    end
  end
end
