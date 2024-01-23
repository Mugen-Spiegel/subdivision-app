module StatusList
    extend ActiveSupport::Concern
  
    
    PARTIAL = "partial"
    PAID = "paid"
    UN_PAID = "unpaid"
    STATUS = [UN_PAID, PAID, PARTIAL]
  end
  