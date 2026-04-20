# frozen_string_literal: true

module Development
  class SeedUserExampleTransactions
    IMAGE_URL = "https://ucarecdn.com/ad8814e0-a147-4ee1-b229-7494aa4026f2/-/format/jpeg/"

    def self.call(email:)
      new(email: email).call
    end

    def initialize(email:)
      @email = email
    end

    def call
      user = User.where("LOWER(email) = ?", email.to_s.strip.downcase).first!
      ensure_tags(user)
      User.transaction { user.transactions.destroy_all; seed_days(user) }
    end

    private

    attr_reader :email

    def ensure_tags(user)
      account = user.account || raise(ActiveRecord::RecordNotFound, "User has no account")
      Accounts::SeedDefaultTags.new(account: account).call
    end

    def seed_days(user)
      date_range.each do |day|
        rand(0..5).times { create_transaction(user, day) }
      end
    end

    def date_range
      start_d = Date.current - 6.months
      (start_d..Date.current).to_a
    end

    def create_transaction(user, day)
      currency = rand(100) < 85 ? "PLN" : "USD"
      base = base_attributes(user, day, currency)
      if rand < 0.75
        create_with_positions(base)
      else
        create_without_positions(base)
      end
    end

    def base_attributes(user, day, currency)
      {
        user: user,
        transaction_date: day,
        status: :ready,
        currency: currency,
        name: "Example receipt #{day}",
        store_name: %w[Biedronka Lidl Żabka Carrefour Auchan].sample,
        store_address: "#{rand(1..120)} Marszałkowska, Warsaw",
        receipt_image_url: nil
      }
    end

    def create_with_positions(attrs)
      amount = random_amount
      positions_attrs = build_positions(amount)
      sum_prices = positions_attrs.sum { |p| p[:total_price] }
      sum_disc = positions_attrs.sum { |p| p[:total_discount] }
      txn = Transaction.create!(attrs.merge(amount: sum_prices, total_discount: sum_disc))
      positions_attrs.each { |p| txn.positions.create!(p) }
      txn.images.create!(image_url: IMAGE_URL)
      ExampleTransactionVat.attach!(txn, sum_prices)
      attach_tag(txn, attrs[:user])
    end

    def create_without_positions(attrs)
      amount = random_amount
      txn = Transaction.create!(attrs.merge(amount: amount, total_discount: random_discount(amount)))
      ExampleTransactionVat.attach!(txn, amount)
      attach_tag(txn, attrs[:user])
    end

    def random_amount
      rand(5.0..1000.0).round(2)
    end

    def random_discount(amount)
      return 0.to_d if rand > 0.35

      (amount * rand(0.01..0.08)).round(2)
    end

    def build_positions(target_total)
      n = rand(1..10)
      chunks = split_amount(target_total, n)
      chunks.map { |chunk| position_row(chunk) }
    end

    def split_amount(total, parts)
      weights = Array.new(parts) { rand + 0.01 }
      wsum = weights.sum
      parts_ = weights.map { |w| (total * (w / wsum)).round(2) }
      parts_[-1] += (total - parts_.sum)
      parts_
    end

    def position_row(chunk)
      d = (chunk * rand(0.0..0.06)).round(2)
      total_discount = d < 0.01 ? 0 : d
      unit_price = (chunk + total_discount).round(2)
      total_price = Transaction::Position.total_price_for(
        quantity: 1,
        unit_price: unit_price,
        total_discount: total_discount
      )
      {
        category: Transaction::Position::CATEGORIES.sample,
        name: "Line item #{SecureRandom.hex(2)}",
        quantity: 1,
        unit_price: unit_price,
        total_discount: total_discount,
        total_price: total_price
      }
    end

    def attach_tag(txn, user)
      tag = user.account.tags.order(:id).sample
      txn.transaction_tags.create!(tag: tag, source: :user)
    end
  end
end
