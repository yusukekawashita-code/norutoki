class UserRouteDeparturesFinder
  def initialize(user, current_time = Time.current)
    @user = user
    @current_time = current_time
  end

  def call
    user.usual_routes
        .ordered
        .map do |usual_route|
      RouteDepartureFinder.new(usual_route, current_time).call
    end
  end

  private

  attr_reader :user, :current_time
end
