class User < ApplicationRecord

    include StatusList
    
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
            :recoverable, :rememberable, :validatable
    belongs_to :subdivision
    has_many :water_billing_transactions
    has_many :monthly_due_transactions
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

    scope :users_total_water_billing_transactions_unpaid_bill, -> (subdivision_id) do 
        joins(:water_billing_transactions )
        .where("water_billing_transactions.is_paid": [UN_PAID, PARTIAL], subdivision_id: subdivision_id)
        .select("
            users.id,
            SUM(CASE
                WHEN water_billing_transactions.is_paid='unpaid' THEN 
                COALESCE(water_billing_transactions.bill_amount,0)
                ELSE (COALESCE(water_billing_transactions.bill_amount,0) - COALESCE(water_billing_transactions.paid_amount,0)) 
            END) as bal
                ")
        .group("users.id")
    end

    scope :users_total_monthly_due_unpaid_bill, -> (subdivision_id) do 
        joins(:monthly_due_transactions )
        .where("monthly_due_transactions.is_paid": [UN_PAID, PARTIAL], subdivision_id: subdivision_id)
        .select("
            users.id,
            SUM(CASE
                WHEN monthly_due_transactions.is_paid='unpaid' THEN 
                COALESCE(monthly_due_transactions.bill_amount,0)
                ELSE (COALESCE(monthly_due_transactions.bill_amount,0) - COALESCE(monthly_due_transactions.paid_amount,0))
            END) as bal
                ")
        .group("users.id")
    end

    scope :user_yearly_monthly_due_bill, -> (user_id, year) do
        joins(:monthly_due_transactions)
        .where(id: user_id, "monthly_due_transactions.year": year)
        .select("
            users.id,
            monthly_due_transactions.bill_amount,
            monthly_due_transactions.month,
            CASE
                WHEN monthly_due_transactions.is_paid='unpaid' THEN 
                COALESCE(monthly_due_transactions.bill_amount,0)
                ELSE (COALESCE(monthly_due_transactions.bill_amount,0) - COALESCE(monthly_due_transactions.paid_amount,0))
            END as balance
                ")
    end

    scope :user_yearly_water_bill, -> (user_id, year) do
        joins(:water_billing_transactions)
        .where(id: user_id, "water_billing_transactions.year": year)
        .select("
            users.id,
            water_billing_transactions.bill_amount,
            water_billing_transactions.month,
            CASE
                WHEN water_billing_transactions.is_paid='unpaid' THEN 
                COALESCE(water_billing_transactions.bill_amount,0)
                ELSE (COALESCE(water_billing_transactions.bill_amount,0) - COALESCE(water_billing_transactions.paid_amount,0))
            END as balance
                ")
    end

    def statement_of_account(year, month)
        subdivision = self.subdivision
        line_items = prepaire_line_items(year, month)
        details = prepaire_details(year, month)

        Receipts::Statement.new(
            title: "Statement of Account",
            details: details,
            recipient: [
                "<b>Bill To</b>",
                "#{self.first_name.titleize} #{self.last_name.titleize}",
                "Block #{self.block}, Lot #{self.lot}, #{self.street.titleize} Street",
                "Barangay #{subdivision.barangay.titleize}, #{subdivision.city.titleize} City, #{subdivision.postal_code}",
            ],
            company: {
            name: subdivision.name,
            address: "#{subdivision.barangay} Barangay, #{subdivision.city.titleize} City",
            email: "",
            phone: "",
            },
            line_items: line_items,
            footer: "Please contact kuya Noel if you have any questions."
        )
    end

    def prepaire_line_items(year, month)
        line_items_water_billing = line_item_water_billing(year, month)
        line_items_monthly_due = line_item_monthly_due(year, month)
        line_items = [["<b>Item</b>", "<b>Quantity</b>", "<b>Amount</b>"]]

        unless line_items_water_billing.nil?
            line_items << [line_items_water_billing&.item, "1 Month", line_items_water_billing&.bill_amount]
        end
        unless line_items_monthly_due.nil?
            line_items << [line_items_monthly_due&.item, "1 Month", line_items_monthly_due&.bill_amount]
        end
        line_items << [nil, "<b>Subtotal</b>", ((line_items_water_billing&.bill_amount || 0) + (line_items_monthly_due&.bill_amount || 0))]
        line_items << [nil, "<b>Total</b>", ((line_items_water_billing&.bill_amount || 0) + (line_items_monthly_due&.bill_amount || 0))]
        line_items
    end

    def line_item_water_billing(year, month)
        self.water_billing_transactions.select("'Water Billing' as item", :bill_amount, :paid_amount).where(month: month, year: year).first
    end

    def line_item_monthly_due(year, month)
        self.monthly_due_transactions.select("'Monthly Dues' as item", :bill_amount, :paid_amount).where(month: month, year: year).first
    end

    def prepaire_water_transaction_details(year, month)
        self.water_billing_transactions.includes(:water_billing).where(year: year, month: month)
    end

    def prepaire_details(year, month)
        water_billing_bill = prepaire_water_transaction_details(year, month)
        details = [
            ["<b>Statement Number:</b>", "#{self.uuid}#{year}#{month}"],
            ["<b>Issue Date:</b>", Date.today.strftime("%B %d, %Y")],
            ["<b>Period:</b>", "#{(Date.today - 30).strftime("%B %d, %Y")} - #{Date.today.strftime("%B %d, %Y")}"]
        ]

        water_billing_bill.each do |bill|
            details << ["<b>Price Per Cubic:</b>", bill.water_billing.per_cubic_price]
            details << ["<b>Current Reading:</b>", bill.current_reading]
            details << ["<b>Previous Reading:</b>", bill.previous_reading]
            details << ["<b>Consumption:</b>", bill.consumption]
            details << ["<b>Maynilad Bill Amount:</b>", bill.water_billing.bill_amount]
        end

        details
    end
    

end
