class ResidenceController < ApplicationController

    def index
        residence_repositories = ResidenceRepositories.new(params, subdivision)
        @residence =  residence_repositories.search_residence
        complete_url = request.original_url
        @sign_in_url = "#{complete_url.gsub("residence","")}subdivision_setting/" + subdivision.uuid + "/prepaire_register_link"
    end
end
