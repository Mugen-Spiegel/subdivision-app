class MonthlyDueTransaction < ApplicationRecord

    include StatusList

    belongs_to :user
    belongs_to :subdivision
    
    validates :is_paid, :bill_amount, :user_id, :year, :month, :monthly_due_id, presence: true

end
