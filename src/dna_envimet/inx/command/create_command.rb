# encoding: UTF-8
module Envimet::EnvimetInx
  # Create envimet buildings
  # @example
  #   Envimet::EnvimetInx.create_building
  def self.create_building
    model = Sketchup.active_model
    selection = model.selection

    if selection.to_a.empty?
      UI.messagebox("Please, select skp objects " \
        "and then press 'Create Building' button.")
      return
    end

    # Get existing envimet buildings
    ents = model.entities
    existing_objs = ents.grep(Sketchup::Group).select do |grp| 
      grp.get_attribute(DICTIONARY, :type) == "building" 
    end

    # Generate ID
    max_id = 1
    unless existing_objs.empty?
      ids = existing_objs.map { |e| e.get_attribute(DICTIONARY, :ID) } 
      max_id += ids.max
    end

    # Skip existing envimet groups
    objs = selection.to_a.reject do |e| 
      e.is_a?(Sketchup::Group) && e.get_attribute(DICTIONARY, "type")
    end

    # return if not objs
    if objs.empty?
      UI.messagebox("Please, select skp objects.")
      return
    end

    # Show the interface
    input = Prompt.show_building_prompt
    
    if input.to_a.empty?
      return
    end
    
    model.start_operation("Create Building", true)
    name, wall, roof, gwall, groof = input

    # Set group properties
    group = model.entities.add_group(objs)
    group.set_attribute(DICTIONARY, :type, "building")
    group.set_attribute(DICTIONARY, :name, name)
    group.set_attribute(DICTIONARY, :wall, wall)
    group.set_attribute(DICTIONARY, :roof, roof)
    group.set_attribute(DICTIONARY, :gwall, gwall)
    group.set_attribute(DICTIONARY, :groof, groof)
    group.set_attribute(DICTIONARY, :ID, max_id)
    
    model.commit_operation
  end
  
  # Create envimet soil
  # @example
  #   Envimet::EnvimetInx.create_soil
  def self.create_soil
    model = Sketchup.active_model
    selection = model.selection

    if selection.to_a.empty?
      UI.messagebox("Please, select skp objects " \
        "and then press 'Create Soil' button.")
      return
    end

    # Skip existing envimet groups
    objs = selection.to_a.reject do |e| 
      e.is_a?(Sketchup::Group) && e.get_attribute(DICTIONARY, :type)
    end

    # return if not objs
    if objs.empty?
      UI.messagebox("Please, select skp objects.")
      return
    end

    # Show the interface
    input = Prompt.show_soil_prompt
    
    return unless input
    
    model.start_operation("Create Soil", true)

    # Set group properties
    group = model.entities.add_group(objs)
    group.set_attribute(DICTIONARY, :type, "soil")
    group.set_attribute(DICTIONARY, :material, input)
    
    model.commit_operation
  end

  # Create envimet simple_plant
  # @example
  #   Envimet::EnvimetInx.create_simple_plant
  def self.create_simple_plant
    model = Sketchup.active_model
    selection = model.selection

    if selection.to_a.empty?
      UI.messagebox("Please, select skp objects " \
        "and then press 'Create Simple plant' button.")
      return
    end

    # Skip existing envimet groups
    objs = selection.to_a.reject do |e| 
      e.is_a?(Sketchup::Group) && e.get_attribute(DICTIONARY, :type)
    end

    # return if not objs
    if objs.empty?
      UI.messagebox("Please, select skp objects.")
      return
    end

    # Show the interface
    input = Prompt.show_simple_plant_prompt
    
    return unless input
    
    model.start_operation("Create Simple plant", true)

    # Set group properties
    group = model.entities.add_group(objs)
    group.set_attribute(DICTIONARY, :type, "simple_plant")
    group.set_attribute(DICTIONARY, :material, input)
    
    model.commit_operation
  end

  # Create envimet source
  # @example
  #   Envimet::EnvimetInx.create_source
  def self.create_source
    model = Sketchup.active_model
    selection = model.selection

    if selection.to_a.empty?
      UI.messagebox("Please, select skp objects " \
        "and then press 'Create Source' button.")
      return
    end

    # Skip existing envimet groups
    objs = selection.to_a.reject do |e| 
      e.is_a?(Sketchup::Group) && e.get_attribute(DICTIONARY, :type)
    end

    # return if not objs
    if objs.empty?
      UI.messagebox("Please, select skp objects.")
      return
    end

    # Show the interface
    input = Prompt.show_source_prompt
    
    return unless input
    
    model.start_operation("Create Source", true)

    # Set group properties
    group = model.entities.add_group(objs)
    group.set_attribute(DICTIONARY, :type, "source")
    group.set_attribute(DICTIONARY, :material, input)
    
    model.commit_operation
  end

  # Create envimet terrain
  # @example
  #   Envimet::EnvimetInx.create_terrain
  def self.create_terrain
    model = Sketchup.active_model
    selection = model.selection

    if selection.to_a.empty?
      UI.messagebox("Please, select skp objects " \
        "and then press 'Create Source' button.")
      return
    end

    # Skip existing envimet groups
    objs = selection.to_a.reject do |e| 
      e.is_a?(Sketchup::Group) && e.get_attribute(DICTIONARY, :type)
    end

    # return if not objs
    if objs.empty?
      UI.messagebox("Please, select skp objects.")
      return
    end
    
    model.start_operation("Create Terrain", true)

    # Set group properties
    group = model.entities.add_group(objs)
    group.set_attribute(DICTIONARY, :type, "terrain")
    
    model.commit_operation
    UI.messagebox("Terrain added.")
  end

  # Create envimet location
  # @example
  #   Envimet::EnvimetInx.set_location
  def self.set_location
    grid = @@preparation.get_value(:grid)

    # Return if grid does not exist (double check)
    unless grid
      return
    end

    min_x = grid.other_info[:min_x]
    min_y = grid.other_info[:min_y]

    # Read location from SKP
    georeference = Sketchup.active_model.attribute_dictionaries["GeoReference"]

    latitude, longitude, locationsource, \
    north = georeference["Latitude"], georeference["Longitude"], \
    Sketchup.active_model.shadow_info["City"], georeference["GeoReferenceNorthAngle"]

    # Get UTM from SKP Point [min grid point]
    pt = [min_x, min_y, 0]
    utm = Sketchup.active_model.point_to_utm(pt)

    # It works fine except some places
    reference_longitude = Sketchup.active_model.shadow_info["TZOffset"] * 15

    # Initialize location
    location = Location.new(locationsource, 
      latitude, 
      longitude, 
      reference_longitude, 
      north, 
      utm)

    # Add location to wrapper class variable
    @@preparation.add_value(:location, location)
  end

  # Set grid from prompt
  # @param bbox [Geom::BoundingBox] of SKP.
  # @example
  #   Envimet::EnvimetInx.create_grid(bbox, "1")
  def self.create_grid(bbox, type)
    model = Sketchup.active_model
    model.start_operation("Set Grid", true)

    model.select_tool(nil)

    bbox, others = Prompt.get_grid_by_prompt(bbox, type)

    unless others.nil?
      # Create grid
      grid = Geometry::Grid.new(bbox, others)
      
      # Save info
      Geometry.generate_grid_group(grid)

      UI.messagebox("Grid calculated. Dimension" \
        " #{grid.other_info[:num_x] + 1}," \
        "#{grid.other_info[:num_y] + 1}," \
        "#{grid.other_info[:num_z]}.")
    else
      UI.messagebox("Calculation Failed.")
      return
    end

    model.commit_operation
  end

  # Create envimet plant3d
  # @example
  #   Envimet::EnvimetInx.create_plant3d
  def self.create_plant3d
    model = Sketchup.active_model
    selection = model.selection

    if selection.to_a.empty?
      UI.messagebox("Please, select skp components " \
        "and then press 'Create Plant3d' button.")
      return
    end
    
    # Select just component instances
    objs = selection.grep(Sketchup::ComponentInstance)
    if objs.to_a.empty?
      UI.messagebox("Please, select skp components.")
      return
    end
    
    # Show the interface
    input = Prompt.show_plant3d_prompt
    
    return unless input
    
    model.start_operation("Create Plant3d", true)

    # Set group properties
    group = model.entities.add_group(objs)
    group.set_attribute(DICTIONARY, :type, "plant3d")
    group.set_attribute(DICTIONARY, :material, input)

    model.commit_operation
  end

  # Create envimet receptor
  # @example
  #   Envimet::EnvimetInx.create_receptor
  def self.create_receptor
    model = Sketchup.active_model
    selection = model.selection

    if selection.to_a.empty?
      UI.messagebox("Please, select just one skp component " \
        "and then press 'Create Receptor' button.")
      return
    end
    
    # Select just component instances
    objs = selection.grep(Sketchup::ComponentInstance)
    if objs.to_a.empty? || objs.to_a.length > 1
      UI.messagebox("Please, select just one skp component.")
      return
    end
    
    # Show the interface
    input = Prompt.show_receptor_prompt
    
    return if input.empty?

    # Get existing receptor name
    ents = model.entities
    existing_objs = ents.grep(Sketchup::Group).select do |grp| 
      grp.get_attribute(DICTIONARY, :type) == "receptor" 
    end

    # Get receptor names
    unique_names = []
    unless existing_objs.empty?
      unique_names = existing_objs.map { |e| e.get_attribute(DICTIONARY, :name) }
      if unique_names.include?(input)
        UI.messagebox("A receptor with this name already exists.\n" \
          "Name must be unique.")
        return
      end
    end

    model.start_operation("Create Receptor", true)

    # Set group properties
    group = model.entities.add_group(objs)
    group.set_attribute(DICTIONARY, :type, "receptor")
    group.set_attribute(DICTIONARY, :name, input)

    model.commit_operation
  end
end # end Envimet::EnvimetInx