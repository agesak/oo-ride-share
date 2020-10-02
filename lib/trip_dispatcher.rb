require 'csv'
require 'time'

require_relative 'passenger'
require_relative 'trip'
require_relative 'driver'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize(directory: './support')
      @passengers = Passenger.load_all(directory: directory)
      @trips = Trip.load_all(directory: directory)
      @drivers = Driver.load_all(directory: directory)
      connect_trips
    end

    def find_passenger(id)
      Passenger.validate_id(id)
      return @passengers.find { |passenger| passenger.id == id }
    end

    def find_driver(id)
      Driver.validate_id(id)
      return @drivers.find { |driver| driver.id == id }
    end

    def request_trip(passenger_id)
      driver = find_next_driver
      raise ArgumentError.new("No drivers are available.") unless driver
      driver.change_status

      passenger = find_passenger(passenger_id)

      new_trip = Trip.new(id: @trips.last.id + 1, passenger_id: passenger_id, start_time: Time.now, end_time: nil, cost: nil, rating: nil, driver: driver)
      new_trip.connect(passenger, driver)

      @trips.push(new_trip)

      return new_trip
    end


    def inspect
      # Make puts output more useful
      return "#<#{self.class.name}:0x#{object_id.to_s(16)} \
              #{trips.count} trips, \
              #{drivers.count} drivers, \
              #{passengers.count} passengers>"
    end

    private
    def find_next_driver
      # select available drivers (no in-progress trips)
      available_drivers = @drivers.filter { |driver| driver.status == :AVAILABLE && driver.trips.all?{ |trip| trip.end_time != nil} }

      new_driver = available_drivers.find { |driver| driver.trips.empty? }
      if new_driver
        return new_driver
      else
        available_drivers.max do |driver|
          sorted_trips = sort_trips_by_end_time(driver)
          Time.now - sorted_trips.last.end_time
        end
      end
    end

    def sort_trips_by_end_time(driver)
      return driver.trips.sort_by { |trip| trip.end_time }
    end

    def connect_trips
      @trips.each do |trip|
        passenger = find_passenger(trip.passenger_id)
        driver = find_driver(trip.driver_id)
        trip.connect(passenger, driver)
      end

      return trips
    end
  end
end
