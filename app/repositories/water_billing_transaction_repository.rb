class WaterBillingTransactionRepository

    attr_accessor :street, :status, :year, :month, :name, :subdivision_id, 
    :first_name, :last_name,  :created_at, :sort_by, :direction, :where_clause, :where_like_clause, :water_billing_transactions
    
    def initialize(params, subdivision_id)
        self.year = params["year"] || Time.now.year
        self.month = params["month"] || "Select month"
        self.first_name = params["first_name"] || ""
        self.last_name = params["last_name"] || ""
        self.subdivision_id = subdivision_id
        self.sort_by = params["sort_by"]
        self.direction = "DESC"
        self.status = params["status"] || "Select status"
        self.street = params["street"] || "Select Street"
        self.where_clause = {}
        self.where_like_clause = ""
    end

    def search_water_billing_transaction
        prepare_where_clause
        WaterBillingTransaction.joins(:user, :water_billing)
        .select("DISTINCT(water_billing_transactions.id) AS id,
            water_billing_transactions.created_at AS created_at,
            water_billing_transactions.month as month,
            water_billing_transactions.consumption AS consumption,
            water_billing_transactions.bill_amount AS bill_amount,
            water_billing_transactions.paid_amount AS paid_amount,
            users.first_name,
            CONCAT('Block ', users.block, 'Lot ', users.lot, ' ', users.street, ' Street') AS address,
            CONCAT(users.first_name,' ', users.last_name) AS name,
            users.id AS user_id,
            CAST(water_billing_transactions.current_reading AS int) AS current_reading,
            CAST(water_billing_transactions.previous_reading AS int) AS previous_reading,
            CAST(water_billings.per_cubic_price AS float) AS per_cubic_price,
            water_billing_transactions.is_paid as is_paid
        ")
        .where(self.where_clause).where(self.where_like_clause)
        .where("water_billing_transactions.subdivision_id = ?", self.subdivision_id)
        .order("#{self.sort_by}": self.direction)
    end

    def prepare_where_clause
        self.where_clause = unless self.month == "Select month"
            {month: Date::MONTHNAMES.index(self.month)}
        else
            {month: ..12}
        end

        unless self.first_name.empty?
            self.where_like_clause += "users.first_name LIKE '%#{self.first_name.downcase}%'" 
        end

        unless self.last_name.empty?
            unless self.first_name.empty?
                self.where_like_clause += " AND "
            end 
            self.where_like_clause += "users.last_name LIKE '%#{self.last_name.downcase}%'" 
        end

        self.where_clause["water_billing_transactions.year"] = self.year

        unless self.status == "Select status"
            self.where_clause["water_billing_transactions.is_paid"] = self.status
        end

        unless self.street == "Select Street"
            self.where_clause["users.street"] = self.street.downcase
        end

        if self.sort_by.nil?
            self.sort_by = "water_billing_transactions.month"
        end
    end

    def after_create_callback(water_billing)
        self.water_billing_transactions = []

        subdivision_latest_transaction = residence_with_latest_transaction(water_billing)

        prepare_latest_transaction(subdivision_latest_transaction, water_billing)

        new_user(water_billing)
        WaterBillingTransaction.insert_all(self.water_billing_transactions)
    end

    def prepare_latest_transaction(subdivision_latest_transaction, water_billing)
        subdivision_latest_transaction.each do |transaction|
            self.water_billing_transactions << {
                is_paid: WaterBillingTransaction::UN_PAID,
                month: water_billing.month,
                year: water_billing.year,
                user_id: transaction.user_id,
                previous_reading: (transaction.current_reading || 0),
                subdivision_id: transaction.subdivision_id,
                water_billing_id: water_billing.id
            }
        end
    end

    def new_user(water_billing)
        User.all_new_user.where(subdivision_id: water_billing.subdivision_id).each do |user|
            self.water_billing_transactions << {
                is_paid: WaterBillingTransaction::UN_PAID,
                month: water_billing.month,
                year: water_billing.year,
                user_id: user.id,
                previous_reading: 0,
                subdivision_id: water_billing.subdivision_id,
                water_billing_id: water_billing.id
            }
        end
    end
    
    def residence_with_latest_transaction(water_billing)
        User.all_users_with_latest_transactions(water_billing.year, water_billing.month).where(subdivision_id: water_billing.subdivision_id)
    end

    def self.after_update_callback(water_billing)
    end
    

    def self.calculate_bill_amount(water_billing_transaction, params)
        unless params["paid_amount"].nil?
            params["paid_amount"] = (params["paid_amount"].to_f  + water_billing_transaction.paid_amount).round(2)
            puts params["paid_amount"].to_f, "asddsadsadsa"
            if ( params["paid_amount"].to_f == water_billing_transaction.bill_amount )
                params["is_paid"] = WaterBillingTransaction::PAID
            elsif
                params["is_paid"] = WaterBillingTransaction::PARTIAL
            end
        end

        unless params["current_reading"].nil?
            params["consumption"] = (params["current_reading"].to_i - water_billing_transaction.previous_reading)
            params["bill_amount"] = (water_billing_transaction.water_billing.per_cubic_price.to_f * params["consumption"].to_f).round(2)
            
        end
        
        params
    end



    def get_monthly_unpaid_bills
        unpaid_bills = {}
        user_ids = Subdivision.where(id: self.subdivision_id).joins(:users).pluck("users.id")
        month = if self.month == "Select month"
            12
        else 
            Date::MONTHNAMES.index(self.month)
        end
        WaterBillingTransaction.users_with_unpaid_bill(user_ids, month, self.year).map do |w| 
            unpaid_bills["#{w.user_id}_#{w.month}"] = w.bal
            previous_month = w.month - 1
        end
        unpaid_bills

    end

    def self.sum_current_reading_by_month(year)
        WaterBillingTransaction.where(year: year).group(:month).sum(:consumption)
    end
end