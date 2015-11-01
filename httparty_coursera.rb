# HTTParty example
require 'httparty'
require 'pp'

class CourseraCourses
  include HTTParty
  
  base_uri 'https://api.coursera.org/api/catalog.v1/courses'
  default_params fields: "smallIcon,shortDescription", q: "search"
  format :json
  
  def self.for term
    get("", query: {query: term})["elements"]
  end
end

pp CourseraCourses.for "ruby"