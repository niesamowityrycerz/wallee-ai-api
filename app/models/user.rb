# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :transactions, dependent: :destroy
  has_one :user_setting, dependent: :destroy, inverse_of: :user

  after_create :create_default_user_setting!

  private

  def create_default_user_setting!
    create_user_setting!(
      currency: UserSetting::DEFAULT_CURRENCY,
      show_vat_details: false
    )
  end
end
