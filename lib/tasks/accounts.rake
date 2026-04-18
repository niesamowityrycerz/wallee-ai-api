# frozen_string_literal: true

namespace :accounts do
  desc "Create a Personal account for users without one and seed default tags"
  task backfill: :environment do
    User.where(account_id: nil).find_each do |user|
      ActiveRecord::Base.transaction do
        account = Account.create!(name: Account::DEFAULT_NAME)
        user.update!(account_id: account.id)
      end
    end
  end
end
