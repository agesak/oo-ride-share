require_relative 'test_helper'

describe "Driver class" do
  describe "Driver instantiation" do
    before do
      @driver = RideShare::Driver.new(
        id: 54,
        name: "Test Driver",
        vin: "12345678901234567",
        status: :AVAILABLE
      )
    end

    it "is an instance of Driver" do
      expect(@driver).must_be_kind_of RideShare::Driver
    end

    it "throws an argument error with a bad ID" do
      expect { RideShare::Driver.new(id: 0, name: "George", vin: "33133313331333133") }.must_raise ArgumentError
    end

    it "throws an argument error with a bad VIN value" do
      expect { RideShare::Driver.new(id: 100, name: "George", vin: "") }.must_raise ArgumentError
      expect { RideShare::Driver.new(id: 100, name: "George", vin: "33133313331333133extranums") }.must_raise ArgumentError
    end

    #Driver.status changed to an optional parameter per interpretation of this test
    it "has a default status of :AVAILABLE" do
      expect(RideShare::Driver.new(id: 100, name: "George", vin: "12345678901234567").status).must_equal :AVAILABLE
    end

    it "raises ArgumentError for status other than :AVAILABLE, :UNAVAILABLE" do
      expect{ RideShare::Driver.new(id: 100, name: "George", vin: "12345678901234567", status: :boogers).status }.must_raise ArgumentError
    end

    it "sets driven trips to an empty array if not provided" do
      expect(@driver.trips).must_be_kind_of Array
      expect(@driver.trips.length).must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :vin, :status, :trips].each do |prop|
        expect(@driver).must_respond_to prop
      end

      expect(@driver.id).must_be_kind_of Integer
      expect(@driver.name).must_be_kind_of String
      expect(@driver.vin).must_be_kind_of String
      expect(@driver.status).must_be_kind_of Symbol
    end
  end

  describe "add_trip method" do
    before do
      pass = RideShare::Passenger.new(
        id: 1,
        name: "Test Passenger",
        phone_number: "412-432-7640"
      )
      @driver = RideShare::Driver.new(
        id: 3,
        name: "Test Driver",
        vin: "12345678912345678"
      )
      @trip = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger: pass,
        start_time: Time.new(2016, 8, 8),
        end_time: Time.new(2018, 8, 9),
        rating: 5
      )
    end

    it "adds the trip" do
      expect(@driver.trips).wont_include @trip
      previous = @driver.trips.length

      @driver.add_trip(@trip)

      expect(@driver.trips).must_include @trip
      expect(@driver.trips.length).must_equal previous + 1
    end
  end

  describe "average_rating method" do
    before do
      @driver = RideShare::Driver.new(
        id: 54,
        name: "Rogers Bartell IV",
        vin: "1C9EVBRM0YBC564DZ"
      )
      trip = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger_id: 3,
        start_time: Time.new(2016, 8, 8),
        end_time: Time.new(2016, 8, 8),
        rating: 5
      )
      @driver.add_trip(trip)
    end

    let(:in_progress_trip) {
      RideShare::Trip.new(id: 1, passenger_id: 54, start_time: Time.now, end_time: nil, cost: nil, rating: nil, driver_id: 4)
    }

    let(:trip2){
      RideShare::Trip.new(
          id: 8,
          driver: @driver,
          passenger_id: 3,
          start_time: Time.new(2016, 8, 8),
          end_time: Time.new(2016, 8, 9),
          rating: 1
      )
    }

    it "returns a float" do
      expect(@driver.average_rating).must_be_kind_of Float
    end

    it "returns a float within range of 1.0 to 5.0" do
      average = @driver.average_rating
      expect(average).must_be :>=, 1.0
      expect(average).must_be :<=, 5.0
    end

    it "returns zero if no driven trips" do
      driver = RideShare::Driver.new(
        id: 54,
        name: "Rogers Bartell IV",
        vin: "1C9EVBRM0YBC564DZ"
      )
      expect(driver.average_rating).must_equal 0
    end

    it "correctly calculates the average rating" do
      @driver.add_trip(trip2)
      expect(@driver.average_rating).must_be_close_to (5.0 + 1.0) / 2.0, 0.01
    end

    it "excludes in progress trips" do
      @driver.add_trip(in_progress_trip)
      @driver.add_trip(trip2)
      expect(@driver.average_rating).must_be_close_to (5.0 + 1.0) / 2.0, 0.01
    end
  end

  describe "total_revenue" do
    # You add tests for the total_revenue method
    before do
      @driver = RideShare::Driver.new(
        id: 54,
        name: "Rogers Bartell IV",
        vin: "1C9EVBRM0YBC564DZ"
      )
      trip1 = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger_id: 3,
        start_time: Time.new(2016, 8, 8),
        end_time: Time.new(2016, 8, 8),
        rating: 5,
        cost: 7
      )
      trip2 = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger_id: 3,
        start_time: Time.new(2016, 8, 8),
        end_time: Time.new(2016, 8, 8),
        rating: 5,
        cost: 10
      )
      @driver.add_trip(trip1)
      @driver.add_trip(trip2)
    end

    let(:in_progress_trip) {
      RideShare::Trip.new(id: 1, passenger_id: 54, start_time: Time.now, end_time: nil, cost: nil, rating: nil, driver_id: 4)
    }

    it "returns float" do
      expect(@driver.total_revenue).must_be_kind_of Float
    end

    it "returns correct calculation for only long trips" do
      expect(@driver.total_revenue).must_be_close_to 10.96, 0.01
    end

    it "returns correct calculation including short trips" do
      trip3 = RideShare::Trip.new(
          id: 8,
          driver: @driver,
          passenger_id: 3,
          start_time: Time.new(2016, 8, 8),
          end_time: Time.new(2016, 8, 8),
          rating: 5,
          cost: 1.50
      )
      @driver.add_trip(trip3)
      expect(@driver.total_revenue).must_be_close_to 12.16, 0.01
    end

    it "return 0 if no driven trips" do
      driver = RideShare::Driver.new(
        id: 54,
        name: "Rogers Bartell IV",
        vin: "1C9EVBRM0YBC564DZ"
      )
      expect(driver.total_revenue).must_equal 0
    end

    it "excludes in progress trips" do
      @driver.add_trip(in_progress_trip)
      expect(@driver.total_revenue).must_be_close_to 10.96, 0.01
    end
  end
end
