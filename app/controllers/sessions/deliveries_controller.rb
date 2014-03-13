module Sessions
  class DeliveriesController < ApplicationController
    def new
      @deliveries = current_market.delivery_schedules.map { |ds| ds.next_delivery.decorate(context: {current_organization: current_organization}) }
    end

    def create
      session[:current_delivery_id] = params[:delivery_id].to_i
      return invalid_delivery_selection if current_delivery.nil?

      if current_delivery.requires_location?
        location_id = params[:location_id][params[:delivery_id]]
        if location = current_organization.locations.find_by(id: location_id)
          session[:current_location] = location.id
        else
          return invalid_delivery_selection
        end
      end

      redirect_to :products
    end

    protected

    def invalid_delivery_selection
      flash.now[:alert] = "Please select a delivery"
      self.new
      return render :new
    end
  end
end
