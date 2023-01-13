# encoding: UTF-8
module Envimet::EnvimetInx
  # Delete envimet objects
  # @example
  #   Envimet::EnvimetInx.delete_envimet_object
  def self.delete_envimet_object
    model = Sketchup.active_model
    selection = model.selection

    if selection.to_a.empty?
      UI.messagebox("Please, select an envimet object" \
        " and then press 'Delete Envimet Object' button.")
        return
    end
      
    ents = selection.to_a.grep(Sketchup::Group).select do |grp| 
      grp.get_attribute(DICTIONARY, :type) != nil &&
      grp.get_attribute(DICTIONARY, :type) != "grid"
    end

    # return if not objs
    if ents.empty?
      UI.messagebox("Please, select envimet objects.")
      return
    end
    
    result = UI.messagebox("Do you want to procede?", MB_YESNO)
    
    model.start_operation("Delete Object", true)
    if result == IDYES && !ents.empty?
      ents.each { |grp| grp.explode }
      UI.messagebox("Envimet Object deleted!")
    end
    model.commit_operation

  end

  # Show envimet inspector
  def self.display_inspector
    model = Sketchup.active_model
    selection = model.selection
    selection.clear
    @@inspector.dialog.show
  end

  # Command to select objects by type
  def self.select_by_type
    model = Sketchup.active_model
    model.start_operation("Select by type", true)

    selection = model.selection
    selection.clear

    type = Prompt.select_by_type_prompt

    return unless type

    ents = model.entities
    envi_entities = ents.grep(Sketchup::Group).select do |grp| 
      grp.get_attribute(DICTIONARY, :type) == type
    end
    selection.add(envi_entities)

    model.commit_operation
  end

  # Get info from envimet groups
  # @return [Tuple] html tr and txt totals 
  def self.get_envimet_entity_info
    model = Sketchup.active_model
    selection = model.selection
    
    groups = selection.grep(Sketchup::Group).reject do |grp| 
      grp.get_attribute(DICTIONARY, "type").nil?
    end

    return unless groups

    values = ""
    total = ""
    tot_buildings = tot_grid = tot_plat3d = 0
    tot_soil = tot_simple_plant = tot_source = 0
    tot_terrain = tot_receptor = 0
    groups.each do |grp|
      type = grp.get_attribute(DICTIONARY, "type")
      id = "#"

      details = nil
      case (type)
      when "building"
        id = grp.get_attribute(DICTIONARY, "ID")
        wall = grp.get_attribute(DICTIONARY, :wall)
        roof = grp.get_attribute(DICTIONARY, :roof)
        gwall = grp.get_attribute(DICTIONARY, :gwall)
        groof = grp.get_attribute(DICTIONARY, :groof)
        bsf = grp.get_attribute(DICTIONARY, :bsf)
        details = [
          "WALL: #{wall}", 
          "ROOF: #{roof}", 
          "GREEN WALL: #{gwall}", 
          "GREEN ROOF: #{groof}",
          "BSF: #{bsf}"
        ].join(" | ") 
        tot_buildings += 1
      when "grid"
        dim_x = grp.get_attribute(DICTIONARY, :dim_x)
        dim_y = grp.get_attribute(DICTIONARY, :dim_y)
        dim_z = grp.get_attribute(DICTIONARY, :dim_z)
        num_x = grp.get_attribute(DICTIONARY, :num_x) + 1
        num_y = grp.get_attribute(DICTIONARY, :num_y) + 1
        num_z = grp.get_attribute(DICTIONARY, :num_z)
        gtype = grp.get_attribute(DICTIONARY, :grid_type)
        rotation = grp.get_attribute(DICTIONARY, :rotation)
        details = [
          "DIM.X: #{dim_x}",
          "DIM.Y: #{dim_y}",
          "DIM.Z: #{dim_z}",
          "X: #{num_x}",
          "Y: #{num_y}",
          "Z: #{num_z}",
          "ROTATION: #{rotation}",
          "TYPE: #{gtype}"
        ].join(" | ")
        tot_grid += 1
      when "plant3d"
        material = grp.get_attribute(DICTIONARY, :material)
        details = "MATERIAL: #{material}"
        tot_plat3d += 1
      when "soil"
        material = grp.get_attribute(DICTIONARY, :material)
        details = "MATERIAL: #{material}"
        tot_soil += 1
      when "simple_plant"
        material = grp.get_attribute(DICTIONARY, :material)
        details = "MATERIAL: #{material}"
        tot_simple_plant += 1
      when "source"
        material = grp.get_attribute(DICTIONARY, :material)
        details = "MATERIAL: #{material}"
        tot_source += 1
      when "terrain"
        material = id
        details = "MATERIAL: #{material}"
        tot_terrain += 1
      when "receptor"
        name = grp.get_attribute(DICTIONARY, :name)
        details = "UNIQUE NAME: #{name}"
        tot_receptor += 1
      else
        # nothing
      end

      table_data = "<tr><td>#{id}</td>" \
      "<td>#{type}</td><td>#{details}</td></tr>"
      
      values << table_data
    end

    total << [
      "N. BUILDING: #{tot_buildings}",
      "N. GRID: #{tot_grid}",
      "N. PLANT3D: #{tot_plat3d}",
      "N. RECEPTOR: #{tot_receptor}",
      "N. SOIL: #{tot_soil}",
      "N. SIMPLE PLANT: #{tot_simple_plant}",
      "N. SOURCE: #{tot_source}",
      "N. TERRAIN: #{tot_terrain}"
    ].join(" ➖ ")
    
    return values, total
  end
end # end Envimet::EnvimetInx