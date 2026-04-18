# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  belongs_to :account, optional: true, inverse_of: :users

  has_many :transactions, dependent: :destroy
  has_one :user_setting, dependent: :destroy, inverse_of: :user

  after_create :create_default_user_setting!
  after_create :ensure_account!

  private

  def ensure_account!
    return if account_id.present?

    account = Account.create!(name: Account::DEFAULT_NAME)
    update!(account_id: account.id)
  end

  def create_default_user_setting!
    create_user_setting!(
      currency: UserSetting::DEFAULT_CURRENCY,
      show_vat_details: false
    )
  end
end
