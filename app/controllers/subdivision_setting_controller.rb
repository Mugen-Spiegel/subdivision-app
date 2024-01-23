class SubdivisionSettingController < ApplicationController
    
    skip_before_action :authenticate_user!, only: [:prepare_register_link]

    def prepare_register_link
        complete_url = request.original_url.split("subdivision_setting")
        unless Subdivision.find_by(uuid: params["id"]).nil?
            redirect_to "/users/sign_up?subdivision_uuid=#{params["id"]}"
        else
            render :file => 'public/404.html', :status => :not_found, :layout => false
        end
    end
end