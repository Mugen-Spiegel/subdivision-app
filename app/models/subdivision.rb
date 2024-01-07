class Subdivision < ApplicationRecord

    has_many :users, -> { where admin: false }
    has_many :water_billing_transactions,  through: :users
    has_many :monthly_dues


    scope :all_users, -> { includes(:users) }
    
end
