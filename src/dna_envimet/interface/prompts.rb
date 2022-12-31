module Envimet::EnvimetInx
  module Prompt

    def self.get_grid_selection
      prompts = [
        "Type",
      ]

      defaults = [
        "equidistant"
      ]
      
      grid_type = Geometry::Grid::GRID_TYPE.values

      options = [grid_type.join("|")]

      input = UI.inputbox(prompts, 
        defaults,
        options, 
        "Select Grid Type", 
        MB_OK)
      
      input.first if input && !input.join.empty? 
    end

    # UI of the grid
    # @param bbox [Array] min point and max point
    # @param type [String] grid type to use 1, 2 or 3
    # @return [Array, Hash] min point, max point, grid info 
    def self.get_grid_by_prompt(bbox, type)
      message = nil
      others = nil

      if type == "equidistant"
        prompts = [
          "Num Z cells", 
          "Dim X(m)", 
          "Dim Y(m)", 
          "Dim Z(m)",
          "Rotation(0°-360° anticlockwise) [0.0 North]:"]
        defaults = [15, 3.0, 3.0, 3.0, 0.0]
        results = UI.inputbox(prompts, 
          defaults, 
          "Create Equidistant Grid")

        if results
          num_z, dim_x, dim_y, dim_z, rotation = results
          others = { 
            grid_type: Geometry::Grid::GRID_TYPE[type],
            dim_x: dim_x,
            dim_y: dim_y,
            dim_z: dim_z,
            num_z: num_z,
            rotation: rotation
          }
          return bbox, others
        end
      elsif type == "telescope"
        message = "Create Telescope Grid"
      elsif type == "combined"
        message = "Create Combined Grid"
      end

      prompts = [
        "Num Z cells", 
        "Dim X(m)", 
        "Dim Y(m)", 
        "Dim Z(m)", 
        "Start Telescope Height", 
        "Telescope",
        "Rotation(0°-360° anticlockwise) [0.0 North]:"
      ]
      defaults = [15, 3.0, 3.0, 3.0, 6.0, 8.0, 0.0]
      results = UI.inputbox(prompts, 
        defaults, 
        message)

      if results
        num_z, dim_x, dim_y, dim_z, \
          start_telescope, telescope, rotation = results
        others = { 
          grid_type: Geometry::Grid::GRID_TYPE[type],
          num_z: num_z,
          dim_x: dim_x,
          dim_y: dim_y,
          dim_z: dim_z,
          telescope: telescope,
          start_telescope_height: start_telescope,
          rotation: rotation
        }
        return bbox, others
      end
    end


    def self.is_custom_code_correct?(code, default="000000")
      code.length == 6 && code != default
    end

    # Select type by prompt
    def self.select_by_type_prompt
      prompts = [
        "Type",
      ]

      defaults = [
        "building"
      ]
      
      envimet_type = [
        "building",
        "grid",
        "soil",
        "simple_plant",
        "plant3d",
        "terrain",
        "source",
        "receptor"
      ].sort

      options = [envimet_type.join("|")]

      input = UI.inputbox(prompts, 
        defaults,
        options, 
        "Select Envimet Entities", 
        MB_OK)
      
      input.first if input && !input.join.empty?
    end

    # UI of the building
    # @return [Tuple] tuple with inputs for group 
    def self.show_building_prompt
      keyword = "building"
      gkeyword = "greening"

      # get materials
      wall = Envimet::EnvimetInx.preparation.materials[keyword].keys.sort
      greening = Envimet::EnvimetInx.preparation.materials[gkeyword].keys.sort

      prompts = [
        "Name", 
        "Wall Material", 
        "Roof Material", 
        "Green Wall Material", 
        "Green Roof Material",
        "BSF (Y/N)",
        "[OPTIONAL] Custom Wall Material Code (E.g. 0000CM)",
        "[OPTIONAL] Custom Roof Material Code (E.g. 0000CM)",
        "[OPTIONAL] Custom Green Wall Material Material Code (E.g. 0000CM)",
        "[OPTIONAL] Custom Green Roof Material Code (E.g. 0000CM)",
      ]

      defaults = [
        "SKP BUILDING",
        "DEFAULT", 
        "DEFAULT", 
        "DEFAULT",
        "DEFAULT",
        "N",
        "000000",
        "000000",
        "000000",
        "000000",
      ]
      
      options = ["", 
        wall.join("|"), 
        wall.join("|"), 
        greening.join("|"), 
        greening.join("|"),
        "Y|N"
      ]

      input = UI.inputbox(prompts, 
        defaults,
        options, 
        "Create Envimet Building", 
        MB_OK)

      if input && !input.join.empty?
        n, w, r, gw, gr, ibsf, cw, cr, cgw, cgr = input

        w = is_custom_code_correct?(cw) ? cw \
          : Envimet::EnvimetInx.preparation.materials[keyword][w]
        r = is_custom_code_correct?(cr) ? cr \
          : Envimet::EnvimetInx.preparation.materials[keyword][r]
        gw = is_custom_code_correct?(cgw) ? cgw \
          : Envimet::EnvimetInx.preparation.materials[gkeyword][gw]
        gr = is_custom_code_correct?(cgr) ? cgr \
          : Envimet::EnvimetInx.preparation.materials[gkeyword][gr]

        bsf = (ibsf == "Y") ? "1" : "0"

        UI.messagebox("[ENVIMET]: Building #{n} #{w} #{r} #{gw} #{gr}")

        return n, w, r, gw, gr, bsf
      end
    end

    def self.show_receptor_prompt
      prompts = [
        "Unique Name"
      ]

      defaults = [
        "SKP RECEPTOR #{rand(0...999999)}"
      ]
      
      options = []

      input = UI.inputbox(prompts, 
        defaults,
        options, 
        "Create Envimet Receptor", 
        MB_OK)

      if input && !input.join.empty?
        name = input.first
        
        name
      end
    end

    # Common 2D elements
    # @param keyword [string] type to select 
    # @return [string] material for group
    def self.show_common_prompt(keyword)
      # get materials
      material = Envimet::EnvimetInx.preparation.materials[keyword].keys.sort

      prompts = [
        "Material", 
        "[OPTIONAL] Custom Material Code (E.g. 0000CM)"
      ]

      defaults = [
        "DEFAULT", 
        "000000"
      ]
      
      options = [
        material.join("|") 
      ]

      input = UI.inputbox(prompts, 
        defaults,
        options, 
        "Create Envimet #{keyword.capitalize}", 
        MB_OK)
      
      if input && !input.join.empty?
        mat, custom_mat = input

        m = is_custom_code_correct?(custom_mat) ? custom_mat \
          : Envimet::EnvimetInx.preparation.materials[keyword][mat]

        UI.messagebox("[ENVIMET]: #{keyword.capitalize} #{mat}")
        return m
      end
    end

    # Show plant3d prompt
    def self.show_plant3d_prompt
      res = show_common_prompt("plant3d")
      res unless res.nil?
    end

    # Show soil prompt
    def self.show_soil_prompt
      res = show_common_prompt("soil")
      res unless res.nil?
    end

    # Show simple plant prompt
    def self.show_simple_plant_prompt
      res = show_common_prompt("simple_plant")
      res unless res.nil?
    end

    # Show source prompt
    def self.show_source_prompt
      res = show_common_prompt("source")
      res unless res.nil?
    end

    # Show rotation prompt
    def self.show_rotation_prompt
      prompts = [
        "Rotation(0°-360° anticlockwise) [0.0 North]:"
      ]
      defaults = [0.0]
      options = []

      input = UI.inputbox(prompts, 
        defaults,
        options, 
        "Edit Grid rotation", 
        MB_OK)
      
      if input && !input.join.empty?
        UI.messagebox("[ENVIMET]: Grid rotation updated.")
        return input.first
      end
    end
  end # end Prompt
end # end Envimet::EnvimetInx