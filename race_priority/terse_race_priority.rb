require 'yaml'
def trip_signature(trip)
	t = trip.dup; t.delete('id'); t.delete('source'); t
end
sources = YAML.load(File.read 'sources.yml')
trips = YAML.load(File.read 'trips.yml')
grouped_trips = trips.group_by{ |t| trip_signature(t) }
unique = []
grouped_trips.each { |s,t| unique << t.max_by{ |t| sources[t['source']]} }
File.open('result.yml', 'w') {|f| f.write unique.to_yaml}