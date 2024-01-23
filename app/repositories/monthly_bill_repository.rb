class MonthlyBillRepository

    attr_accessor :monthly_due_bill, :water_billing_bill, :balance
    
    def monthly_due_bill_list(user_id, year)
        self.monthly_due_bill = User.user_yearly_monthly_due_bill(user_id, year)
    end

    def monthly_water_bill_list(user_id, year)
        self.water_billing_bill = User.user_yearly_water_bill(user_id, year)
    end

    def user_bill_list(user_id, year)

        monthly_due_bill_list(user_id, year)
        monthly_water_bill_list(user_id, year)
        self.balance = {}
        prepaire_user_balance(self.monthly_due_bill, year)
        prepaire_user_balance(self.water_billing_bill, year)
        puts self.balance, "asdsasddas", self.monthly_due_bill.to_json, self.water_billing_bill.to_json
        self.balance
    end

    def prepaire_user_balance(bills, year)
        bills.each do |bill|
            if self.balance["#{bill.month}"].nil?
                self.balance[bill.month] = {
                    year: year,
                    month: bill["month"],
                    total_bill: bill["bill_amount"] || 0,
                    total_balance: bill["balance"] || 0
                }
            else
                self.balance["#{bill.month}"][:total_bill] += bill["bill_amount"]
                self.balance["#{bill.month}"][:total_balance] += bill["balance"]
                self.balance["#{bill.month}"][:month] = bill["month"]
                self.balance["#{bill.month}"][:year] = year
            end
        end
    end
end