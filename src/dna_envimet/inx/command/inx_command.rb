# encoding: UTF-8
module Envimet::EnvimetInx
  # Set building matrix
  # @example
  #   Envimet::EnvimetInx.set_building_matrix
  def self.set_building_matrix
    grid = @@preparation.get_value(:grid)

    unless grid
      return
    end

    # Select all
    visible_grp = self.collect_envimet_type("building")
    
    # Hide other entities
    ents_to_hide = self.hide_all_except(visible_grp)

    # Initialize Intersection
    intersection = Intersection.new
    pts = [] 
    params = [] 

    visible_grp.each do |grp|
      partial_pts, partial_params = intersection.get_inteserction(grid, grp, "building")
      pts += partial_pts
      params += partial_params
    end

    intersection_top = pts.map(&:first).compact
    intersection_bottom = pts.map(&:last).compact
    intersection_id = params.map(&:first).compact

    # Get x y
    num_x = grid.other_info[:num_x]
    num_y = grid.other_info[:num_y]

    top_matrix = Geometry::Grid.base_matrix_2d(num_x, num_y, 0)
    bottom_matrix = Geometry::Grid.base_matrix_2d(num_x, num_y, 0)
    id_matrix = Geometry::Grid.base_matrix_2d(num_x, num_y, 0)
    zero_matrix = Geometry::Grid.base_matrix_2d(num_x, num_y, 0)

    unless pts.empty? || params.empty?
      top_matrix = intersection.get_matrix(intersection_top, grid, top_matrix)
      bottom_matrix = intersection.get_matrix(intersection_bottom, grid, bottom_matrix)
      id_matrix = intersection.get_matrix(intersection_id, grid, id_matrix, text=true)
    end

    @@preparation.add_value(:top_matrix, intersection.get_envimet_matrix(top_matrix))
    @@preparation.add_value(:bottom_matrix, intersection.get_envimet_matrix(bottom_matrix))
    @@preparation.add_value(:id_matrix, intersection.get_envimet_matrix(id_matrix))
    @@preparation.add_value(:zero_matrix, intersection.get_envimet_matrix(zero_matrix))

    # Get the buildings
    ids = intersection_id.map { |bld| bld[2] }
    ids.uniq!
    building_grp = get_building_grp_by_uuid(ids)
    @@preparation.add_value(:building, building_grp)

    # Show other entities
    ents_to_hide.each { |e| e.visible = true }
  end

  # Get pixel from component
  def self.create_pixel_from_component(cmp, grid, 
      x, y, code,
      name="SKP PLANT3D")
    centroid = cmp.bounds.center
    pixel_x = grid.other_info[:x_axis].find_index { |n| n > centroid.x + x }
    pixel_y = grid.other_info[:y_axis].find_index { |n| n > centroid.y + y }

    if (pixel_x.nil? || pixel_x == 0) || 
      (pixel_y.nil? || pixel_y == 0)
      return
    end

    pixel = Pixel.new(name, 
      code, 
      pixel_x, 
      pixel_y)
    
    pixel
  end

  # Set receptor matrix
  # @example
  #   Envimet::EnvimetInx.set_receptor_matrix
  def self.set_receptor_matrix
    grid = @@preparation.get_value(:grid)

    unless grid
      return
    end
    list = []
    
    # Select all receptor
    receptor_grps = self.collect_envimet_type("receptor")

    receptor_grps.each do |grp|
      name = grp.get_attribute(DICTIONARY, :name)
      x = grp.bounds.min.x
      y = grp.bounds.min.y

      components = grp.entities.grep(Sketchup::ComponentInstance)
      components.each do |cmp|
        pixel = create_pixel_from_component(cmp, grid, x, y, name, name)
        next unless pixel

        list << pixel
      end
    end
    @@preparation.add_value(:receptor, list)
  end

  # Set receptor matrix
  # @example
  #   Envimet::EnvimetInx.set_plant3d_matrix
  def self.set_plant3d_matrix
    grid = @@preparation.get_value(:grid)

    unless grid
      return
    end
    tree = []
    
    # Select all plat3d
    plant3d_grps = self.collect_envimet_type("plant3d")

    plant3d_grps.each do |grp|
      material = grp.get_attribute(DICTIONARY, :material)
      x = grp.bounds.min.x
      y = grp.bounds.min.y

      components = grp.entities.grep(Sketchup::ComponentInstance)
      components.each do |cmp|
        pixel = create_pixel_from_component(cmp, grid, x, y, material)
        next unless pixel

        tree << pixel
      end
    end
    @@preparation.add_value(:plant3d, tree)
  end

  # Set common matrix for soil, simple_plant, others
  # @param type [String] type of envimet entity.
  # @param type [Symbol] a symbol to save inside preparation
  # @example
  #   Envimet::EnvimetInx.set_common_matrix("soil", :soil_matrix)
  def self.set_common_matrix(type, symbol, def_mat=nil)
    grid = @@preparation.get_value(:grid)

    unless grid
      return
    end

    # Select all
    visible_grp = self.collect_envimet_type(type)
    
    # Hide other entities
    ents_to_hide = self.hide_all_except(visible_grp)

    # Initialize Intersection
    intersection = Intersection.new
    pts = [] 
    params = [] 

    visible_grp.each do |grp|
      partial_pts, partial_params = intersection.get_inteserction(grid, grp, type)
      pts += partial_pts
      params += partial_params
    end

    intersection_id = params.map(&:first).compact

    # Get x y
    num_x = grid.other_info[:num_x]
    num_y = grid.other_info[:num_y]

    # Read the default material and go ahead with intersections
    default_mat = def_mat.nil? ? preparation.materials[type]["DEFAULT"] : def_mat

    id_matrix = Geometry::Grid.base_matrix_2d(num_x, num_y, default_mat)

    unless pts.empty? || params.empty?
      id_matrix = intersection.get_matrix(intersection_id, 
        grid, id_matrix, text=true)
    end

    # Add the matrix to wrapper class variable
    @@preparation.add_value(symbol, 
      intersection.get_envimet_matrix(id_matrix))
    
    # Show other entities
    ents_to_hide.each { |e| e.visible = true }
  end

  # Create envimet DEM matrix.
  # @example
  # Envimet::EnvimetInx.set_dem_matrix
  def self.set_dem_matrix
    type = "terrain"
    grid = @@preparation.get_value(:grid)

    unless grid
      return
    end

    # Select all
    visible_grp = self.collect_envimet_type("terrain")
    
    # Hide other entities
    ents_to_hide = self.hide_all_except(visible_grp)

    # Initialize Intersection
    intersection = Intersection.new
    pts = [] 
    params = [] 

    visible_grp.each do |grp|
      partial_pts, partial_params = intersection.get_inteserction(grid, grp, "terrain")
      pts += partial_pts
      params += partial_params
    end

    intersection_top = pts.map(&:first).compact

    # Get x y
    num_x = grid.other_info[:num_x]
    num_y = grid.other_info[:num_y]

    # Read the default material and go ahead with intersections
    top_matrix = Geometry::Grid.base_matrix_2d(num_x, num_y, 0)
    
    unless pts.empty? || params.empty?
      top_matrix = intersection.get_matrix(intersection_top, grid, top_matrix)
    end
    # Add the matrix to wrapper class variable
    @@preparation.add_value(:dem_matrix, intersection.get_envimet_matrix(top_matrix))

    ents_to_hide.each { |e| e.visible = true }
  end

  # Create envimet entities
  # @example
  #   Envimet::EnvimetInx.create_inx_model
  def self.create_inx_model
    model = Sketchup.active_model
    selection = model.selection

    # Get existing envimet grids
    objs = selection.to_a.select do |e| 
      e.is_a?(Sketchup::Group) && \
      e.get_attribute(DICTIONARY, :type) == "grid"
    end
    
    # No selection and no grids
    if selection.to_a.empty? || objs.empty?
      UI.messagebox("Please, select an envimet grid.")
      return
    end
    
    # Just one grid allowed
    if objs.length > 1
      UI.messagebox("Please, select just one " \
        "envimet grid.")
      return
    end
    
    # georeferenced check
    unless model.georeferenced?
      UI.messagebox("Model is not georeferenced.\n" \
      "Please,fix location with Envimet Space.")
    else
      UI.messagebox("Model is georeferenced.\n" \
        "Please, Check only if reference longitude " \
        "is correct with Envimet Space.")
    end

    # Reset preparation
    @@preparation.reset

    # recreate grid from group
    grid = Geometry.create_grid_from_group(objs.first)

    # Add grid to preparation
    @@preparation.add_value(:grid, grid)

    # Calculation
    set_location
    set_building_matrix
    set_common_matrix("soil", :soil_matrix)
    set_common_matrix("simple_plant", :plant2d_matrix, "")
    set_common_matrix("source", :source_matrix, "")
    set_plant3d_matrix
    set_receptor_matrix
    set_dem_matrix
    true
  end
  
  # Get file name
  # @example
  #   Envimet::EnvimetInx.get_default_file_name
  def self.get_default_file_name
    current_path = Sketchup.active_model.path
    file_name = current_path.empty? ? "Envimet" : \
      File.basename(current_path, ".*") # get skp file name
    file_name
  end

  # Create envimet model calling just one method
  # @example
  #   Envimet::EnvimetInx.write_inx_file
  def self.write_inx_file
    if defined?(@@preparation).nil?
      UI.messagebox("Please, create envimet model first.")
      return
    end

    # Initialize Inx class
    inx = IO::Inx.new

    # Fast validation
    validation = @@preparation.get_value(:grid)\
      .other_info[:x_axis].empty?

    unless validation
      doc = inx.create_xml(@@preparation)

      # Something was wrong...
      if doc.nil?
        UI.messagebox("Error...")
        return
      end

      full_path = UI.savepanel(title = "Save Envimet INX", 
        filename = "#{get_default_file_name}.INX")
      inx.write_xml(doc, full_path) unless full_path.nil?
    end
  end
end # end Envimet::EnvimetInx
