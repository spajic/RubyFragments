require 'yaml'
require 'ostruct'
require 'pry'

class Trip
	attr_reader :attributes

	def initialize(hash)
		@attributes = OpenStruct.new
		load_from_hash(hash)
	end

	class << self
    	attr_accessor :sources_priorities
  	end

	def load_from_hash(hash)
		attributes.id 			= hash['id']
		attributes.from 		= hash['from']
		attributes.to 			= hash['to']
		attributes.start_time 	= hash['start_time']
		attributes.start_date 	= hash['start_date']
		attributes.end_time 	= hash['end_time']
		attributes.end_date 	= hash['end_date']
		attributes.amount 		= hash['amount']
		attributes.source 		= hash['source']
	end

	def signature
		[attributes.from, 		attributes.to, 
		 attributes.start_time, attributes.start_date,
		 attributes.end_time,	attributes.end_date,
		 attributes.amount]
	end

	def duplicates?(other)
		signature == other.signature
	end

	def ==(other)
		attributes.to_h == other.attributes.to_h
	end

	def source_priority
		Trip.sources_priorities[attributes.source]
	end

	def to_h
		# OpenStruct.to_h даёт ключи в виде :symbols, а надо 'строки'
		Hash[attributes.to_h.map {|k, v| [k.to_s, v] }]
	end
end

class Trips
	attr_reader :trips
	def initialize(yaml_file_name = nil)
		@trips = []
		load_from_yaml_file(yaml_file_name) if yaml_file_name
	end

	def retain_unique_trips_with_largest_priorities!
		grouped_by_signature = trips.group_by{|t| t.signature}
		@trips = []
		grouped_by_signature.each do |k,v|
			@trips << v.max_by {|t| t.source_priority}
		end
	end

	def load_from_yaml_file(file_name)
		@trips = YAML.load(File.read(file_name)).
			map {|trip_hash| Trip.new(trip_hash)}
	end

	def save_to_yaml_file(file_name)
		File.open(file_name,'w') do |f| 
   			f.write (@trips.map{|t| t.to_h}).to_yaml
		end
	end
end

Trip.sources_priorities = YAML.load(File.read("sources.yml"))
t = Trips.new('trips.yml')
t.retain_unique_trips_with_largest_priorities!
t.save_to_yaml_file('result.yml')