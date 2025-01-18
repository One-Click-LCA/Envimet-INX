module Envimet::EnvimetInx
  module IO
    class Inx

      if Sketchup.version.to_i > 23
        require "rexml/document"
      else
        SketchUp.require "rexml/document"
      end

      include REXML

      def create_childs(root,
          element,
          childs,
          attributes = {})
        base_element = Element.new(element)

        childs.each do |k, v|
          child_element = Element.new(k)
          child_element.text = v
          base_element.add_element(child_element,
            attributes)
        end

        root << base_element
      end

      def create_xml(preparation)
        if envimet_object_validation(preparation)
          return
        end

        # get envimet objects
        grid = preparation.get_value(:grid)
        location = preparation.get_value(:location)
        building = preparation.get_value(:building)
        plant3d = preparation.get_value(:plant3d)
        receptor = preparation.get_value(:receptor)

        # get envimet matrix
        top_matrix = preparation.get_value(:top_matrix)
        bottom_matrix = preparation.get_value(:bottom_matrix)
        id_matrix = preparation.get_value(:id_matrix)
        zero_matrix = preparation.get_value(:zero_matrix)
        soil_matrix = preparation.get_value(:soil_matrix)
        plant2d_matrix = preparation.get_value(:plant2d_matrix)
        terrain_matrix = preparation.get_value(:dem_matrix)
        source_matrix = preparation.get_value(:source_matrix)

        # set attribute
        num_x = grid.other_info[:num_x]
        num_y = grid.other_info[:num_y]
        num_z = grid.other_info[:num_z]
        attribute_2d = {
          "type" => "matrix-data",
          "dataI" => num_x,
          "dataJ" => num_y
        }

        doc = Document.new
        root = Element.new("ENVI-MET_Datafile")

        useTelescoping_grid, verticalStretch, \
        startStretch, useSplitting, grid_Z = 0, 0, 0, 1, num_z

        if grid.other_info[:grid_type] == :telescope
          useTelescoping_grid = 1
          verticalStretch = grid.other_info[:telescope]
          startStretch = grid.other_info[:start_telescope_height]
          useSplitting = 0
        elsif grid.other_info[:grid_type] == :combined
          useTelescoping_grid = 1
          verticalStretch = grid.other_info[:telescope]
          startStretch = grid.other_info[:start_telescope_height]
          useSplitting = 1
        end

        header = {
          "filetype" => "INPX ENVI-met Area Input File",
          "version" => "440",
          "revisiondate" => Time.now,
          "remark" => "Created with Envimet::EnvimetInx",
          "checksum" => "6104088",
          "encryptionlevel" => "0"
        }
        base_data = {
          "modelDescription" => "A brave new area",
          "modelAuthor" => " ",
          "modelcopyright" => "The creator or distributor is responsible for following Copyright Laws"
        }
        model_geometry = {
          "grids-I" => num_x,
          "grids-J" => num_y,
          "grids-Z" => grid_Z,
          "dx" => grid.dim_x.to_m,
          "dy" => grid.dim_y.to_m,
          "dz-base" => grid.dim_z.to_m,
          "useTelescoping_grid" => useTelescoping_grid,
          "useSplitting" => useSplitting,
          "verticalStretch" => verticalStretch,
          "startStretch" => startStretch,
          "has3DModel" => "0",
          "isFull3DDesign" => "0"
        }
        nesting_area = {
          "numberNestinggrids" => "0",
          "soilProfileA" => "000000",
          "soilProfileB" => "000000"
        }
        location_data = {
          "modelRotation" => grid.other_info[:rotation].nil? ? \
            0.0 : grid.other_info[:rotation],
          "projectionSystem" => "UTM",
          "realworldLowerLeft_X" => location.utm[:x],
          "realworldLowerLeft_Y" => location.utm[:y],
          "locationName" => location.name,
          "location_Longitude" => location.longitude.nil? ? \
            0.0 : location.longitude,
          "location_Latitude" => location.latitude.nil? ? \
            0.0 : location.latitude,
          "locationTimeZone_Name" => " ",
          "locationTimeZone_Longitude" => location.reference_longitude
        }
        default_settings = {
          "commonWallMaterial" => preparation.materials['building']['DEFAULT'],
          "commonRoofMaterial" => preparation.materials['building']['DEFAULT']
        }
        buildings_2D = {
          "zTop" => top_matrix,
          "zBottom" => bottom_matrix,
          "buildingNr" => id_matrix,
          "fixedheight" => zero_matrix
         }
        simpleplants_2D = { "ID_plants1D" => plant2d_matrix }
        soils_2D = { "ID_soilprofile" => soil_matrix }
        dem = { "terrainheight" => terrain_matrix }
        source_2D = { "ID_sources" => source_matrix }

        create_childs(root,
          "Header",
          header)

        create_childs(root,
          "baseData",
          base_data)

        create_childs(root,
          "modelGeometry",
          model_geometry)

        create_childs(root,
          "nestingArea",
          nesting_area)

        create_childs(root,
          "locationData",
          location_data)

        create_childs(root,
          "defaultSettings",
          default_settings)

        create_childs(root,
          "buildings2D",
           buildings_2D,
           attribute_2d)

        create_childs(root,
          "simpleplants2D",
          simpleplants_2D,
          attribute_2d)

        unless plant3d == []
          plant3d.each do |plt|
            plant3d_info = {
              "rootcell_i" => plt.i,
              "rootcell_j" => plt.j,
              "rootcell_k" => 0,
              "plantID" => plt.code,
              "name" => plt.name,
              "observe" => 0 }
            create_childs(root,
              "threeDimplants",
              plant3d_info)
          end
        end

        unless receptor == []
          receptor.each do |pix|
            receptors_info = {
              "cell_i" => pix.i,
              "cell_j" => pix.j,
              "name" => pix.code
            }
            create_childs(root,
              "Receptors",
              receptors_info)
          end
        end

        create_childs(root,
          "soils2D",
          soils_2D,
          attribute_2d)
        create_childs(root,
          "dem",
          dem,
          attribute_2d)
        create_childs(root,
          "sources2D",
          source_2D,
          attribute_2d)

        unless building == []
          building.each do |bld|
            roof_material = bld.get_attribute("ENVIMET", :roof)
            wall_material = bld.get_attribute("ENVIMET", :wall)
            green_roof = bld.get_attribute("ENVIMET", :groof).nil? \
              ? " " : bld.get_attribute("ENVIMET", :groof)
            green_wall = bld.get_attribute("ENVIMET", :gwall).nil? \
              ? " " : bld.get_attribute("ENVIMET", :gwall)
            uuid = bld.get_attribute("ENVIMET", :ID)
            name = bld.get_attribute("ENVIMET", :name)
            bsf = bld.get_attribute("ENVIMET", :bsf)

            building_info = {
              "BuildingInternalNr" => uuid,
              "BuildingName" => name,
              "BuildingWallMaterial" => wall_material,
              "BuildingRoofMaterial" => roof_material,
              "BuildingFacadeGreening" => green_wall,
              "BuildingRoofGreening" => green_roof,
              "ObserveBPS" => bsf
            }
            create_childs(root, "Buildinginfo", building_info)
          end
        end

        doc << root

        doc
      end

      def write_xml(doc, full_path)
        out = ""
        formatter = Formatters::Pretty.new(0, true)
        formatter.compact = true
        formatter.write(doc, out)

        adapt_xml_text(out)

        # this because inx is not a standard xml
        temp = out.split("\n").reject { |c| c.empty? }

        # create file
        File.open(full_path, "w") do |file|
          file.write(temp.join("\n"))
        end

        UI.messagebox("INX file written.")
      end

      private

      def adapt_xml_text(text)
        text.gsub!("§", "\n")
        text.gsub!("\'", "\"")
        text.gsub!("threeDimplants", "3Dplants")
      end

      def envimet_object_validation(preparation)
        preparation.get_value(:grid).nil? || \
        preparation.get_value(:location).nil?
      end

    end # end Inx
  end # end IO
end # end Envimet::EnvimetInx
