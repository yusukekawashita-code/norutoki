class HomeController < ApplicationController
  def index
    return unless current_user

    @route_departures = UserRouteDeparturesFinder.new(current_user).call
  end
end
