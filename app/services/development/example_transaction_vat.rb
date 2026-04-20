# frozen_string_literal: true

module Development
  module ExampleTransactionVat
    module_function

    def attach!(txn, amount)
      total_vat = (amount * rand(0.08..0.23)).round(2)
      total_vat = [ total_vat, 0.01 ].max
      vat_main = (total_vat * 0.85).round(2)
      vat_sec = (total_vat - vat_main).round(2)
      txn.vat_components.create!(
        [
          { vat_group: "A", rate_percent: 23, vat_amount: vat_main },
          { vat_group: "B", rate_percent: 8, vat_amount: vat_sec }
        ]
      )
      txn.update!(total_vat: total_vat)
    end
  end
end
