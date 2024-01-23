class MonthlyDueTransactionRepository

    attr_accessor :bill_amount, :is_current, :subdivision_id

    def initialize(params, subdivision_id)
        self.bill_amount = params["amount"]
        self.is_current = true
        self.subdivision_id = subdivision_id
    end
    
    def self.create_monthly_due_transaction(subdivision_id)
        monthly_due_transaction = []
        monthly_due = subdivision_monthly_due(subdivision_id)
        User.where(subdivision_id: subdivision_id).each do |user|
            monthly_due_transaction << {
                is_paid: MonthlyDueTransaction::UN_PAID,
                bill_amount: monthly_due.amount,
                user_id: user.id,
                year: Time.now.year,
                month: Time.now.month,
                monthly_due_id: monthly_due.id,
            }
        end

        MonthlyDueTransaction.insert_all(monthly_due_transaction)
    end

    def self.subdivision_monthly_due(subdivision_id)
        MonthlyDue.where(subdivision_id: subdivision_id, is_current: "true").first
    end
end