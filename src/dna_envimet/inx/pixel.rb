module Envimet::EnvimetInx
  class Pixel
    ONE = 1

    attr_reader :name, :code, :i, :j

    def initialize(name, code, i=0, j=0)
      @name = name
      @code = code
      @i = i + ONE
      @j = j + ONE

    end
  end # end Pixel
end # end Envimet::EnvimetInx
