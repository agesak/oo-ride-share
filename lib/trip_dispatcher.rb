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
      drivers = @drivers.select{|driver| (driver.status == :AVAILABLE)}
      # list of drivers with rides in progress
      busy_drivers = drivers.map{|driver| find_in_progress_trips(driver)}
      # exclude drivers with rides in progress
      available_drivers = drivers.select{|driver| !busy_drivers.include?(driver.id)}
      driver = select_driver(available_drivers)

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

    def find_in_progress_trips(driver)
      running = driver.trips.select{|trip| trip.end_time == nil}
      # if there are running trips, return the driver id
      unless running.empty?
        return driver.id
      end
    end

    def select_driver(drivers)
      # select first driver who has never driven (if there are multiple)
      driver = drivers.find{|driver| driver.trips.empty?}
      # assumes preference for driver who has never driven over driver with ride long time ago
      if driver
        return driver
      end
      # select driver # select first driver who has never driven (if there are multiple)
      hash = {}
      drivers.each do |driver|
        # find most recent trip
        most_recent_trip = driver.trips.map{|trip| trip.end_time}.sort[-1]
        hash[driver.id] = most_recent_trip
      end
      # find driver with most recent trip
      driver_id = hash.max_by{|driver, trip_date| trip_date}
      # this method literally exists on line 24
      return drivers.find{|driver| driver.id == driver_id}
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
