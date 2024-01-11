module ApplicationHelper
    def sort_link(column:, label:)
        if column == params[:column]
            link_to(label, water_billing_transaction_subdivision_path(column: column, direction: next_direction), {:style=>'text-decoration: none; color: white;'})
          else
            link_to(label, water_billing_transaction_subdivision_path(column: column, direction: 'asc'), {:style=>'text-decoration: none; color: white;'})
          end
      end

    def next_direction
        params[:direction] == 'asc' ? 'desc' : 'asc'
    end

    def sort_indicator
        tag.span(class: "sort sort-#{params[:direction]}")
    end

    def year_list
        (2013..Time.now.year).to_a.reverse
    end

    def month_list
        Date::MONTHNAMES.compact.unshift("Select month")
    end

    def sort_column
        [["MONTH", "water_billing_transactions.month"], [ "NAME", "users.first_name"], ["STATUS", "water_billing_transactions.is_paid"]]
    end

    def status_list
        WaterBillingTransaction::STATUS.map do |s|
            [s.capitalize(), s]
        end.unshift("Select status")
    end

    def street_list
        Subdivision.joins(:users).where("subdivisions.id": current_user.subdivision_id).select("users.street").pluck(:street).uniq.map{|s| s.capitalize}.compact.unshift("Select Street")
    end

    def subdivision
        unless current_user.nil?
            current_user.subdivision
        end
    end

    def _subdivision(uuid)
        Subdivision.find_by(uuid: uuid)
    end

    def money_format(value)
        number_to_currency(value, unit:"₱")
    end

    def system_percentage(subdivision_consumption, residence_consumption)
        subdivision_consumption.to_f / residence_consumption.to_f * 100.0
    end
    
    def cubic_sign
        "m³"
    end
end
