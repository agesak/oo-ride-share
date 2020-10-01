require_relative 'test_helper'

describe "Passenger class" do

  describe "Passenger instantiation" do
    before do
      @passenger = RideShare::Passenger.new(id: 1, name: "Smithy", phone_number: "353-533-5334")
    end

    it "is an instance of Passenger" do
      expect(@passenger).must_be_kind_of RideShare::Passenger
    end

    it "throws an argument error with a bad ID value" do
      expect do
        RideShare::Passenger.new(id: 0, name: "Smithy")
      end.must_raise ArgumentError
    end

    it "sets trips to an empty array if not provided" do
      expect(@passenger.trips).must_be_kind_of Array
      expect(@passenger.trips.length).must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :phone_number, :trips].each do |prop|
        expect(@passenger).must_respond_to prop
      end

      expect(@passenger.id).must_be_kind_of Integer
      expect(@passenger.name).must_be_kind_of String
      expect(@passenger.phone_number).must_be_kind_of String
      expect(@passenger.trips).must_be_kind_of Array
    end
  end


  describe "trips property" do
    before do
      # TODO: you'll need to add a driver at some point here.
      @passenger = RideShare::Passenger.new(
        id: 9,
        name: "Merl Glover III",
        phone_number: "1-602-620-2330 x3723",
        trips: []
        )
      trip = RideShare::Trip.new(
        id: 8,
        passenger: @passenger,
        start_time: Time.new(2016, 8, 8),
        end_time: Time.new(2016, 8, 9),
        rating: 5,
        driver_id: 1
        )

      @passenger.add_trip(trip)
    end

    it "each item in array is a Trip instance" do
      @passenger.trips.each do |trip|
        expect(trip).must_be_kind_of RideShare::Trip
      end
    end

    it "all Trips must have the same passenger's passenger id" do
      @passenger.trips.each do |trip|
        expect(trip.passenger.id).must_equal 9
      end
    end
  end

  describe "net_expenditures AND total_time_spent" do
    before do
      trips = RideShare::Trip.load_all(directory: "support", file_name: "trips.csv")
      pass_trips = trips.select{|trip| trip.passenger_id == 54}
      @passenger_54 = RideShare::Passenger.new(id: 54, name: "Fifty-Four", phone_number: "123456789", trips: pass_trips)
      @passenger_empty = RideShare::Passenger.new(id: 54, name: "Fifty-Four", phone_number: "123456789", trips: [])
    end

    let(:in_progress_trip) {
      RideShare::Trip.new(id: 1, passenger_id: 54, start_time: Time.now, end_time: nil, cost: nil, rating: nil, driver_id: 4)
    }

    describe "net_expenditures" do

      it "calculates net expenditures" do
        expect(@passenger_54.net_expenditures).must_equal 40
      end

      it "returns 0 expenditures for no trips" do
        expect(@passenger_empty.net_expenditures).must_equal 0
      end

      it "excludes in progress trips" do
        @passenger_54.add_trip(in_progress_trip)
        expect(@passenger_54.net_expenditures).must_equal 40
      end
    end

    describe "total_time_spent" do
      it "calculates total duration" do
        expect(@passenger_54.total_time_spent).must_equal 4228.0
      end

      it "returns a duration of 0 seconds for no trips" do
        expect(@passenger_empty.total_time_spent).must_equal 0
      end

      it "exludes in progress trips" do
        @passenger_54.add_trip(in_progress_trip)
        expect(@passenger_54.total_time_spent).must_equal 4228.0
      end

    end
  end
end
