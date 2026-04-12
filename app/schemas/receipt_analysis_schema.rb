# frozen_string_literal: true

class ReceiptAnalysisSchema < RubyLLM::Schema
  string :store_name, description: "Name of the store where the purchase was made"
  string :store_address, description: "Full address of the store including street, city, and postal code"
  string :transaction_date, description: "Date of the transaction in ISO 8601 format (YYYY-MM-DD)"
  string :currency, description: "ISO 4217 currency code (e.g. USD, EUR, PLN)"
  number :total_amount, description: "Total amount paid on the receipt"
  number :total_discount, description: "Total discount amount applied on the receipt, 0 if none"
  # OpenAI structured output requires every property in `required`; use null when VAT total is absent.
  optional :total_vat,
           description: "Total VAT amount on the receipt (e.g. SUMA PTU on Polish fiscal receipts). Use null if not shown." do
    number description: "Total VAT amount"
  end
  array :vat_components,
        description: "Per VAT group breakdown from the receipt summary (e.g. PTU per stawka). Use an empty array if unavailable." do
    object do
      string :vat_group,
             enum: Transaction::VatComponent::VAT_GROUPS,
             description: "Polish fiscal VAT group letter (A–E) as printed"
      number :rate_percent,
             description: "VAT rate for this group as printed on the receipt (percent)"
      number :vat_amount,
             description: "VAT amount (PTU) for this group"
    end
  end

  array :positions, description: "List of individual items/products on the receipt" do
    object do
      string :name, description: "Product name as printed on the receipt (original language; do not translate)"
      number :quantity, description: "Quantity purchased"
      number :unit_price, description: "Price per single unit of the product"
      number :total_price,
             description: "Line total after discount (quantity × unit_price − line total_discount)"
      string :category, enum: Transaction::Position::CATEGORIES,
             description: "Product category from the predefined list"
      number :total_discount, description: "Discount applied to this specific item, 0 if none"
    end
  end
end
