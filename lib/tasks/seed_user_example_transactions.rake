# frozen_string_literal: true

namespace :users do
  desc <<~DESC.squish
    Delete ALL transactions for the user identified by EMAIL, then seed ~6 months of example
    data (0–5 transactions per day, uniform). Destructive. Example: EMAIL=user@example.com rake users:seed_example_transactions
  DESC
  task seed_example_transactions: :environment do
    email = ENV.fetch("EMAIL")
    Development::SeedUserExampleTransactions.call(email: email)
    puts "Seeded example transactions for #{email.inspect}"
  end
end
