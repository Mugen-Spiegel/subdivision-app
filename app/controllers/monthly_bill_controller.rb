class MonthlyBillController < ApplicationController

    before_action :set_residence

    def index
        monthly_bill_repository = MonthlyBillRepository.new
        @bills = monthly_bill_repository.user_bill_list(@residence.id, params[:year] || Time.now.year)
    end


    def bill
        respond_to do |format|
            format.json
            format.pdf { 
                send_data @residence.statement_of_account(params[:year], params[:month]).render,
                filename: "#{current_user.created_at.strftime("%Y-%m-%d")}-gorails-receipt.pdf",
                type: "application/pdf",
                disposition: :inline # or :attachment to download
             }
            format.html
          end
    end

    private

    def set_residence
        @residence = User.find_by(uuid: params[:id])
    end

end
