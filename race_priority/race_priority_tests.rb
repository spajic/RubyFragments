require 'minitest/autorun'
require 'pry'

require_relative 'race_priority'

module TripsFixtures
	def trips_setup
		@sources_priorities_hash = {
			'gillbus'=> 10,
			'etraffic'=> 9,
			'infobus'=> 8
		} 
		@trip_hash_1 = {
			'id' => 		1,
			'from'=> 		"Москва (Красногвардейская)",
  			'to'=> 			"Санкт-Петербург, Автовокзал Обводный кан. 36",
  			'start_time'=> 	"16:00",
  			'start_date'=> 	"26.11.2015",
  			'end_time'=> 	"03:30",
  			'end_date'=> 	"27.11.2015",
  			'amount'=> 		"1356 RUB",
  			'source'=> 		"gillbus" 
  		}
  		@trip_hash_2 = {
			'id' => 		2,
			'from'=> 		"Москва (Красногвардейская)",
  			'to'=> 			"Санкт-Петербург, Автовокзал Обводный кан. 36",
  			'start_time'=> 	"16:00",
  			'start_date'=> 	"26.11.2015",
  			'end_time'=> 	"03:30",
  			'end_date'=> 	"27.11.2015",
  			'amount'=> 		"1356 RUB",
  			'source'=> 		"etraffic" 
  		}
  		@trip_hash_4 = {
			'id' => 		4,
			'from'=> 		"Москва, м. Комсомольская, Басманный пер. д.4",
  			'to'=> 			"Санкт-Петербург, Автовокзал Обводный кан. 36",
  			'start_time'=> 	"21:10",
  			'start_date'=> 	"26.11.2015",
  			'end_time'=> 	"08:40",
  			'end_date'=> 	"27.11.2015",
  			'amount'=> 		"1175 RUB",
  			'source'=> 		"gillbus" 
  		}
  		Trip.sources_priorities = @sources_priorities_hash
  		@t1 = Trip.new(@trip_hash_1)
  		@t2 = Trip.new(@trip_hash_2)
  		@t4 = Trip.new(@trip_hash_4)
	end
end

class TripTest < MiniTest::Unit::TestCase
	include TripsFixtures

	def setup
		trips_setup
	end

	def test_loads_from_hash_and_provide_attributes
		assert_equal @trip_hash_1['id'], @t1.attributes.id
		assert_equal @trip_hash_1['from'], @t1.attributes.from
		assert_equal @trip_hash_1['to'], @t1.attributes.to
		assert_equal @trip_hash_1['start_time'], @t1.attributes.start_time
		assert_equal @trip_hash_1['start_date'], @t1.attributes.start_date
		assert_equal @trip_hash_1['end_time'], @t1.attributes.end_time
		assert_equal @trip_hash_1['end_date'], @t1.attributes.end_date
		assert_equal @trip_hash_1['amount'], @t1.attributes.amount
		assert_equal @trip_hash_1['source'], @t1.attributes.source
	end

	def test_signature
		assert_equal [	
			@trip_hash_1['from'], 		@trip_hash_1['to'], 
			@trip_hash_1['start_time'], @trip_hash_1['start_date'],
			@trip_hash_1['end_time'], 	@trip_hash_1['end_date'], 
			@trip_hash_1['amount'] 
		], 
		@t1.signature
	end

	def test_duplicates_positive_correctness
		assert @t1.duplicates?(@t2)
	end

	def test_duplicates_negative_correctness
		refute @t1.duplicates?(@t4)
	end

	def test_source_priority
		assert_equal @sources_priorities_hash[@trip_hash_1['source']], 
					 @t1.source_priority
	end

	def test_to_h
		assert_equal @trip_hash_1, @t1.to_h
	end
end # TripTest


class TripsTest < MiniTest::Unit::TestCase
	include TripsFixtures

	def setup 
		trips_setup

		@yaml_string = '---
- id: 1
  from: "Москва (Красногвардейская)"
  to: "Санкт-Петербург, Автовокзал Обводный кан. 36"
  start_time: "16:00"
  start_date: "26.11.2015"
  end_time: "03:30"
  end_date: "27.11.2015"
  amount: "1356 RUB"
  source: "gillbus"
- id: 2
  from: "Москва (Красногвардейская)"
  to: "Санкт-Петербург, Автовокзал Обводный кан. 36"
  start_time: "16:00"
  start_date: "26.11.2015"
  end_time: "03:30"
  end_date: "27.11.2015"
  amount: "1356 RUB"
  source: "etraffic"'
  		@test_file_name = 'test.yml'

  		File.open(@test_file_name, 'w') do |f|
  			f.write @yaml_string
  		end
	end

	def teardown
		File.delete(@test_file_name)
	end

	def test_load_from_yaml_file
		t = Trips.new
		t.load_from_yaml_file(@test_file_name)
		assert_equal [@t1, @t2], t.trips
	end

	def test_save_to_yaml_file
		t = Trips.new
		t.trips << @t1 << @t2
		generated_file_name = 'test_generated.yml'
		t.save_to_yaml_file(generated_file_name)
		assert_equal YAML.load(@yaml_string), YAML.load(File.read generated_file_name)
		File.delete generated_file_name
	end

	def test_retain_unique_trips_with_largest_priorities!
		t = Trips.new
		t.trips << @t1 << @t2 << @t4
		t.retain_unique_trips_with_largest_priorities!
		assert_equal [@t1, @t4], t.trips
	end

end #TripsTest