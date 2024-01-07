class ApplicationController < ActionController::Base
    before_action :authenticate_user!

    rescue_from CanCan::AccessDenied do |exception|
        render :file => 'public/403.html', :status => :forbidden, :layout => false
      end
    


    private
    
    def subdivision
        current_user.subdivision
    end
end
