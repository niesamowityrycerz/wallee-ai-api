# frozen_string_literal: true

namespace :transaction_positions do
  desc "Backfill total_price from quantity, unit_price, and total_discount"
  task backfill_total_price: :environment do
    Transaction::Position.find_each do |position|
      computed = Transaction::Position.total_price_for(
        quantity: position.quantity,
        unit_price: position.unit_price,
        total_discount: position.total_discount
      )
      position.update_column(:total_price, computed)
    end
  end
end
