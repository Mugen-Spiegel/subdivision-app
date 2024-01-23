class WaterBillingTransactionController < ApplicationController

    before_action :set_water_billing_transaction, only: %i[  update destroy ]
  
    # GET /water_billing_transactions or /water_billing_transactions.json
    def index
      @water_billing_transaction = WaterBillingTransactionRepository.new(params, subdivision.id)
      @total = {
        "current_reading": "N/A",
        "previous_reading": "N/A",
        "consumption": 0,
        "bill_amount": 0,
        "monthly_due": 0,
        "total_payable": 0,
        "paid_amount": 0,
        "balance": 0,
      }
        @unpaid_bills = @water_billing_transaction.get_monthly_unpaid_bills
        @water_billing_transaction = @water_billing_transaction.search_water_billing_transaction
    end
  
    # POST /water_billing_transactions or /water_billing_transactions.json
    def create
      @water_billing_transaction = WaterBillingTransaction.new(water_billing_transaction_params)
  
      respond_to do |format|
        if @water_billing_transaction.save
          format.html { redirect_to water_billing_transaction_url(@water_billing_transaction), notice: "Water billing transaction was successfully created." }
          format.json { render :show, status: :created, location: @water_billing_transaction }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @water_billing_transaction.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /water_billing_transactions/1 or /water_billing_transactions/1.json
    def update
      params = WaterBillingTransactionRepository.calculate_bill_amount(@water_billing_transaction, water_billing_transaction_params)
      if @water_billing_transaction.update(params)
        render json: @water_billing_transaction.to_json, status: :ok
      else
        render json: @water_billing_transaction.errors, status: :unprocessable_entity 
      end
    end
  
    # DELETE /water_billing_transactions/1 or /water_billing_transactions/1.json
    def destroy
      @water_billing_transaction.destroy!
  
      respond_to do |format|
        format.html { redirect_to water_billing_transactions_url, notice: "Water billing transaction was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_water_billing_transaction
        @water_billing_transaction = WaterBillingTransaction.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def water_billing_transaction_params
        params.require(:water_billing_transaction).permit(:current_reading, :previous_reading, :paid_amount, :id, :subdivision_id, :water_billing_id)
      end
end
  