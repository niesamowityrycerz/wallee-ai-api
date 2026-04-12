# frozen_string_literal: true

namespace :user_settings do
  desc "Create default UserSetting rows for users that do not have one"
  task backfill: :environment do
    scope = User.left_outer_joins(:user_setting).where(user_settings: { id: nil })
    count = 0
    scope.find_each do |user|
      user.create_user_setting!(
        currency: UserSetting::DEFAULT_CURRENCY,
        show_vat_details: false
      )
      count += 1
    end
    puts "Created #{count} user_setting record(s)."
  end
end
