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

    def average_rating
      ratings = @trips.map{|trip| trip.rating.to_f}
      unless ratings.empty?
        return (ratings.sum/ratings.length).round(1)
      end
      return 0
    end

    private

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