class NextDeparturesController < ApplicationController
  before_action :require_login

  def index
    current_time = Time.current

    @route_departures = current_user.usual_routes
                                    .ordered
                                    .includes(timetables: :departures)
                                    .map do |usual_route|
      RouteDepartureFinder.new(usual_route, current_time).call
    end
  end
end
