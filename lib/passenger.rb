require_relative 'csv_record'

module RideShare
  class Passenger < CsvRecord
    attr_reader :name, :phone_number, :trips

    def initialize(id:, name:, phone_number:, trips: [])
      super(id)

      @name = name
      @phone_number = phone_number
      @trips = trips
    end

    def add_trip(trip)
      @trips << trip
    end

    def net_expenditures
      completed_trips = remove_in_progress_trips
      total = completed_trips.map{|trip| trip.cost}
      unless total.empty?
        return total.sum
      end
      return 0
    end

    def total_time_spent
      completed_trips = remove_in_progress_trips
      total_duration = completed_trips.map{|trip| trip.duration}
      unless total_duration.empty?
        return total_duration.sum
      end
      return 0
    end

    private

    def remove_in_progress_trips
      return @trips.select{|trip| trip.end_time != nil}
    end

    def self.from_csv(record)
      return new(
        id: record[:id],
        name: record[:name],
        phone_number: record[:phone_num]
      )
    end
  end
end
