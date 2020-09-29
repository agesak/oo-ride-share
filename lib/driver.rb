#test driver code

require_relative 'passenger'
require_relative 'trip'
require_relative 'trip_dispatcher'

require "time"

# CSV.read(
#     full_path,
#     headers: true,
#     header_converters: :symbol,
#     converters: :numeric
# ).map { |record| from_csv(record) }


def from_csv(record)
  return RideShare::Trip.new(
      id: record[:id],
      passenger_id: record[:passenger_id],
      start_time: Time.parse(record[:start_time]),
      end_time: Time.parse(record[:end_time]),
      cost: record[:cost],
      rating: record[:rating]
  )
end

csv = CSV.read("../support/trips.csv")
csv = csv[1]
hash = {id: csv[0].to_i,
        driver_id: csv[1].to_i,
        passenger_id: csv[2].to_i,
        start_time: csv[3],
        end_time: csv[4],
        cost: csv[5].to_i,
        rating: csv[6].to_i
}

trip = from_csv(hash)
puts trip.start_time
puts trip.end_time
puts trip.end_time - trip.start_time


