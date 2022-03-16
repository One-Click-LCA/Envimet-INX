module Envimet::EnvimetInx
  class Preparation
    attr_reader :objects, :materials

    def initialize
      @objects = {}
      @materials = Envimet::EnvimetInx.load_settings(
        "envimet-materials.json")
    end

    def add_value(name, value)
      objects[name] = value
    end

    def get_value(name)
      objects[name]
    end

    def reset
      @objects = {}
    end
  end # end Preparation
end # end Envimet::EnvimetInx
