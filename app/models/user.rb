class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
            :recoverable, :rememberable, :validatable
    belongs_to :subdivision
    has_many :water_billing_transactions
    has_many :monthly_due_transaction
    validates :first_name, :middle_name, :last_name, :block, :lot, :street, presence: true
    scope :all_users_with_latest_transactions, ->(year, month) do
        if month > 1
            month -= 1
        else
            year = Time.now.year.to_i - 1       
            month = 12
        end
        joins(:water_billing_transactions)
        .where("water_billing_transactions.year": year, "water_billing_transactions.month": month, "users.admin": false)
        .select("water_billing_transactions.id AS transaction_id,
            users.id AS user_id, 
            water_billing_transactions.year as year,
            water_billing_transactions.month as month,
            users.subdivision_id AS subdivision_id, 
            water_billing_transactions.current_reading AS current_reading")
    end

    scope :all_new_user, -> { 
        left_joins(:water_billing_transactions).where("users.admin=false AND water_billing_transactions.user_id IS ?", nil)  
    }
end
