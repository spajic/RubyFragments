class IntelligentLife
  def self.home_planet
  	@home_planet
  end
  def self.home_planet=(x)
  	@home_planet=x
  end
end

class Terran < IntelligentLife
  self.home_planet = "Earth"
end

class Martian < IntelligentLife
  self.home_planet = "Mars"
end

puts Terran.home_planet
puts Martian.home_planet
