class ResidenceController < ApplicationController


    before_action :residence, only: %i[ show ]

    def index
        residence_repositories = ResidenceRepositories.new(params, subdivision)
        @residence =  residence_repositories.search_residence
        complete_url = request.original_url
        @sign_in_url = "#{complete_url.gsub("residence","")}subdivision_setting/" + subdivision.uuid + "/prepare_register_link"
    end

    def show

    end

    private

    def residence
        @residence = User.find_by(uuid: params[:id])
    end
end
