class StopsController < ApplicationController

  def index
    departure_stop = Station.where(name: params[:from]).first
    arrival_stop = Station.where(name: params[:to]).first

    time_after = params[:time]
    time_before = (time_after.to_time + (params[:range].to_i * 60 * 60)).to_time.strftime('%I:%M%p')
    if time_before.to_time < time_after.to_time
      time_before = "11:59:59PM"
    end
    
    @trips = []
    departure_stop.trains.each do |train|
      departure_stop_confirm = train.stops.where(station: departure_stop).where("departure_time >= '#{time_after}' and departure_time <= '#{time_before}'").first
      arrival_stop_confirm = train.stops.where(station: arrival_stop).first
      if departure_stop_confirm && arrival_stop_confirm
        direction_confirm = arrival_stop_confirm[:id] > departure_stop_confirm[:id]
      end
      if arrival_stop_confirm && departure_stop_confirm && direction_confirm
        stops = train.stops.where(station: departure_stop).first, arrival_stop_confirm, train
        @trips << stops.as_json
      end
    end
  end
end
