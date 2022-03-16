module Envimet::EnvimetInx
  class Location

    attr_reader :name, :latitude, :longitude, \
    :reference_longitude, :utm, :rotation

    def initialize(name, latitude, longitude,
                   reference_longitude=15.0,
                   rotation=0, utm=nil)
      @name = name
      @latitude = latitude
      @longitude = longitude
      @reference_longitude = reference_longitude
      @rotation = rotation
      @utm = {x: utm.x, y: utm.y, letter: utm.zone_letter}

    end
  end # end Location
end # end Envimet::EnvimetInx
