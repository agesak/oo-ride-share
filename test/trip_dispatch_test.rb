require_relative 'test_helper'

TEST_DATA_DIRECTORY = 'test/test_data'

describe "TripDispatcher class" do
  def build_test_dispatcher
    return RideShare::TripDispatcher.new(
      directory: TEST_DATA_DIRECTORY
    )
  end

  describe "Initializer" do
    it "is an instance of TripDispatcher" do
      dispatcher = build_test_dispatcher
      expect(dispatcher).must_be_kind_of RideShare::TripDispatcher
    end

    it "establishes the base data structures when instantiated" do
      dispatcher = build_test_dispatcher
      [:trips, :passengers].each do |prop|
        expect(dispatcher).must_respond_to prop
      end

      expect(dispatcher.trips).must_be_kind_of Array
      expect(dispatcher.passengers).must_be_kind_of Array
      # expect(dispatcher.drivers).must_be_kind_of Array
    end

    it "loads the development data by default" do
      # Count lines in the file, subtract 1 for headers
      trip_count = %x{wc -l 'support/trips.csv'}.split(' ').first.to_i - 1

      dispatcher = RideShare::TripDispatcher.new

      expect(dispatcher.trips.length).must_equal trip_count
    end
  end

  describe "passengers" do
    describe "find_passenger method" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "throws an argument error for a bad ID" do
        expect{ @dispatcher.find_passenger(0) }.must_raise ArgumentError
      end

      it "finds a passenger instance" do
        passenger = @dispatcher.find_passenger(2)
        expect(passenger).must_be_kind_of RideShare::Passenger
      end
    end

    describe "Passenger & Trip loader methods" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "accurately loads passenger information into passengers array" do
        first_passenger = @dispatcher.passengers.first
        last_passenger = @dispatcher.passengers.last

        expect(first_passenger.name).must_equal "Passenger 1"
        expect(first_passenger.id).must_equal 1
        expect(last_passenger.name).must_equal "Passenger 8"
        expect(last_passenger.id).must_equal 8
      end

      it "connects trips and passengers" do
        dispatcher = build_test_dispatcher
        dispatcher.trips.each do |trip|
          expect(trip.passenger).wont_be_nil
          expect(trip.passenger.id).must_equal trip.passenger_id
          expect(trip.passenger.trips).must_include trip
        end
      end
    end
  end

  describe "drivers" do
    describe "find_driver method" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "throws an argument error for a bad ID" do
        expect { @dispatcher.find_driver(0) }.must_raise ArgumentError
      end

      it "finds a driver instance" do
        driver = @dispatcher.find_driver(2)
        expect(driver).must_be_kind_of RideShare::Driver
      end
    end

    describe "Driver & Trip loader methods" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "accurately loads driver information into drivers array" do
        first_driver = @dispatcher.drivers.first
        last_driver = @dispatcher.drivers.last

        expect(first_driver.name).must_equal "Driver 1 (unavailable)"
        expect(first_driver.id).must_equal 1
        expect(first_driver.status).must_equal :UNAVAILABLE
        expect(last_driver.name).must_equal "Driver 4 (longest time since last trip)"
        expect(last_driver.id).must_equal 4
        expect(last_driver.status).must_equal :AVAILABLE
      end

      it "connects trips and drivers" do
        dispatcher = build_test_dispatcher
        dispatcher.trips.each do |trip|
          expect(trip.driver).wont_be_nil
          expect(trip.driver.id).must_equal trip.driver_id
          expect(trip.driver.trips).must_include trip
        end
      end
    end
  end

  describe "request trip" do

    before do
      @dispatcher = build_test_dispatcher
      #driver3 is second AVAILABLE in test/test_date/drivers.csv, but with no trips, and should be selected to drive first
      @first_trip = @dispatcher.request_trip(1)
      #select driver 4
      @second_trip = @dispatcher.request_trip(1)
    end

    it "returns a trip object" do
      expect(@first_trip).must_be_instance_of RideShare::Trip
    end

    it "updates the passenger list with new trip" do
      passenger1 = @dispatcher.find_passenger(1)
      expect(passenger1.trips.last).must_equal @second_trip
    end

   it "updates the driver list with new trip" do
     driver3 = @dispatcher.find_driver(3)
     expect(driver3.trips.last).must_equal @first_trip
   end

    it "selects new drivers first from AVAILABLE drivers" do
      expect(@first_trip.driver_id).must_equal 3
    end

    it "selects based on time from last trip" do
      # driver4 added to test/test_data/drivers.csv and a trip added to test/test_data/trip.csv
      # driver4 last trip ended before driver2's last trip so driver4 should be selected to driver after driver3
      driver4 = @dispatcher.find_driver(4)
      expect(@second_trip.driver).must_equal driver4

    end

    it "changes driver status" do
      #driver2 also AVAILABLE in test/test_data/drivers.csv and should be selected last
      driver2 = @dispatcher.find_driver(2)
      before_status = driver2.status
      #select driver2
      @dispatcher.request_trip(1)
      after_status = driver2.status
      expect(before_status).must_equal :AVAILABLE
      expect(after_status).must_equal :UNAVAILABLE
    end

    it "raises an Argument Error if no available drivers" do
      #in test/test_data/drivers.csv, there are three AVAILABLE drivers
      #select driver2
      @dispatcher.request_trip(1)
      expect{@dispatcher.request_trip(1)}.must_raise ArgumentError
    end

  end

end
