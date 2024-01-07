class WaterBillingRepository
    
    attr_accessor :params, :subdivision_id, :subdivision, :last_transaction, :consumption, :where_clause, :status, :month, :year

    def initialize(params, subdivision_id)
        self.subdivision_id = subdivision_id
        self.params = params
        self.status = params["status"] || "Select status"
        self.year = params["year_list"] || Time.now.year
        self.month =  params["month"] || "Select month"
        self.where_clause = {}
    end

    def search_water_billing
        self.where_clause["subdivision_id"] = self.subdivision_id

        self.where_clause["year"] = self.year

        unless self.month == "Select month"
            self.where_clause["month"] = Date::MONTHNAMES.index(self.params["month"])
        end
        
        unless self.status == "Select status"
            self.where_clause["is_paid"] = self.status
        end
        get_all
    end

    def get_all
        WaterBilling.includes(:photos).where(self.where_clause).select(
            :id,
            :month,
            :mother_meter_current_reading,
            :mother_meter_previous_reading,
            :consumption,
            :is_paid,
            :bill_amount,
            :per_cubic_price,
            :paid_amount,
            :number_residence
        ).order(month: :desc)
    end

    def create
        get_all_residence
        ids_count = get_all_id.count
        get_last_bill
        WaterBilling.create(
            month: Date::MONTHNAMES.index(self.params["month"]),
            year: self.params["year"],
            mother_meter_current_reading: self.params["mother_meter_current_reading"],
            mother_meter_previous_reading: self.last_transaction&.mother_meter_current_reading || 0,
            consumption: current_consumption,
            is_paid: WaterBilling::UN_PAID,
            per_cubic_price: price_per_cubic(ids_count).round(2),
            subdivision_id: self.subdivision_id,
            number_residence: User.where(subdivision_id: self.subdivision_id, admin: false).count
        )
    end

    def get_all_residence
        self.subdivision = Subdivision.all_users.find(self.subdivision_id)
    end

    def get_all_id
        self.subdivision.users.pluck(:id)
    end

    def get_last_bill
        self.last_transaction = WaterBilling.where(subdivision_id: self.subdivision_id)&.last
    end

    def price_per_cubic(ids_count)
        current_consumption / ids_count
    end

    def current_consumption
        self.params["mother_meter_current_reading"].to_f - (self.last_transaction&.mother_meter_current_reading || 0)
    end

    def self.set_up_update_param(water_billing, params)
        unless params["paid_amount"].nil?
            params["paid_amount"] = water_billing.paid_amount + params["paid_amount"].to_f
        end
        
        params
    end
end