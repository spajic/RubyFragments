require 'yaml'

sources = YAML.load(File.read("sources.yml"))
#p sources

trips_yml = YAML.load(File.read("trips.yml"))

class Trip
	attr_reader :id, :from, :to, :start_time, :end_time, 
	:start_date, :end_date, :amount, :source
	def initialize(args, sources)
		@sources = sources
		read_from_yml_hash(args)
	end
	def read_from_yml_hash(args)
		@id = args['id']
		@from = args['from']
		@to = args['to']
		@start_time = args['start_time']
		@end_time = args['end_time']
		@start_date = args['start_date']
		@end_date = args['end_date']
		@amount = args['amount']
		@source = args['source']
	end

	def duplicates(other)
		return true if (from == other.from and
			to == other.to and
			start_time == other.start_time and
			amount == other.amount)
		return false
	end

	def source_priority
		@sources[source]
	end

	def to_s 
		from.to_s + ';' +
		to.to_s + ';' + 
		start_time.to_s + ';' + 
		end_time.to_s + ';' + 
		amount.to_s
	end

	def to_yml_hash
		yh = {}
		yh['id'] = id
		yh['from'] = from
		yh['to'] = to
		yh['start_time'] = start_time
		yh['end_time'] = end_time
		yh['start_date'] = start_time
		yh['end_date'] = end_time
		yh['amount'] = amount
		yh['source'] = source
		return yh
	end
end

trips = []
trips_yml.each {|el| trips.push(Trip.new(el, sources)) }

trips_grouped_by_s = {}
trips.each do |t| 
	if (trips_grouped_by_s[t.to_s] == nil)
		trips_grouped_by_s[t.to_s] = [t] 
	else
		trips_grouped_by_s[t.to_s] << (t)
	end
end

unique_trips = []

trips_grouped_by_s.each do |key, value|  
	sorted = value.sort{|el| el.source_priority}
	unique_trips.push sorted.last
end

res = []
unique_trips.each {|el| res.push(el.to_yml_hash)}

File.open('result.yml','w') do |f| 
   f.write res.to_yaml
end

