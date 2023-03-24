module Envimet::EnvimetInx
  class Pixel
    attr_accessor :i, :j
   
    attr_reader :name, :code

    def initialize(name, code, i=0, j=0)
      @name = name
      @code = code
      @i = i
      @j = j

    end
  end # end Pixel
end # end Envimet::EnvimetInx
