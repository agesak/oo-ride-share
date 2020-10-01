require_relative "csv_record"

module RideShare
  class Driver < RideShare::CsvRecord
    attr_reader :id, :name, :vin, :status, :trips

    def initialize(id:, name:, vin:, status: :AVAILABLE, trips: [])
      super(id)

      @name = name
      @vin = validate_vin(vin)
      @status = validate_status(status)
      @trips = trips
    end

    def add_trip(trip)
      @trips << trip
    end

    def change_status
      if @status == :UNAVAILABLE
        @status = :AVAILABLE
      else
        @status = :UNAVAILABLE
      end
    end

    def average_rating
      completed_trips = remove_in_progress_trips
      ratings = completed_trips.map{ |trip| trip.rating.to_f }
      unless ratings.empty?
        return (ratings.sum/ratings.length).round(1)
      end
      return 0
    end

    def total_revenue
      completed_trips = remove_in_progress_trips
      revenue = completed_trips.map { |trip| trip.cost.to_f }
      unless revenue.empty?
        # below logic assumes RideShare company forgoes $1.65 fee when trip.cost < 1.65 (company still makes 20% charge from ride)
        num_long_trips = revenue.filter { |trip_cost| trip_cost >= 1.65 }.length
        return ((revenue.sum - (1.65 * num_long_trips)) * 0.8).round(2)
      end
      return 0
    end

    private

    def remove_in_progress_trips
      return @trips.select{|trip| trip.end_time != nil}
    end

    def validate_vin(vin)
       raise ArgumentError.new("VIN must be 17 characters") if vin.length != 17
       return vin
    end

    def validate_status(status)
      status = status.to_sym
      raise ArgumentError.new("Status must be :AVAILABLE or :UNAVAILABLE") unless [:AVAILABLE, :UNAVAILABLE].include?(status)
      return status
    end

    def self.from_csv(record)
      return new(
        id: record[:id],
        name: record[:name],
        vin: record[:vin],
        status: record[:status]
      )
    end

  end
end