class WaterBillingTransaction < ApplicationRecord

    include StatusList
    
    belongs_to :user
    belongs_to :water_billing
    belongs_to :subdivision
   
    # Dito na ko
    after_update -> { WaterBillingTransactionRepository.after_update_callback(self) }
    
    scope :users_with_unpaid_bill, -> (user_id, month, year) do
        where(is_paid: [UN_PAID, PARTIAL], user_id: user_id, month: ..month, year: year)
        .select("
            water_billing_transactions.id, 
            water_billing_transactions.user_id,
            water_billing_transactions.month,
            CASE 
                WHEN water_billing_transactions.is_paid='unpaid' THEN 
                COALESCE(water_billing_transactions.bill_amount,0)
                ELSE (COALESCE(water_billing_transactions.bill_amount,0) - COALESCE(water_billing_transactions.paid_amount,0)) 
            END as bal
                ")
        .distinct("water_billing_transactions.month")
    end
    
end
