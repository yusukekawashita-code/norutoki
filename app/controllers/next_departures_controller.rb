class NextDeparturesController < ApplicationController
  before_action :require_login

  def index
    @route_departures = UserRouteDeparturesFinder.new(current_user).call
  end
end
