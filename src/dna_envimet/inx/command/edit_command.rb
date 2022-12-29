# encoding: UTF-8
module Envimet::EnvimetInx
  def self.initial_selection(model, type)
    selection = model.selection

    if selection.to_a.empty?
      UI.messagebox("Please, select envimet #{type} " \
        "to edit then press 'Edit #{type.capitalize}' button.")
        return
    end
      
    # Get existing envimet objs
    existing_objs = selection.to_a.grep(Sketchup::Group).select do |grp| 
      grp.get_attribute(DICTIONARY, :type) == type 
    end
    
    if existing_objs.empty?
      UI.messagebox("Please, select envimet #{type}.")
        return
    end

    existing_objs
  end

  # Edit building
  # @example
  #   Envimet::EnvimetInx.edit_building
  def self.edit_building
    model = Sketchup.active_model
    objs = initial_selection(model, "building")
    return unless objs
    
    # Show the interface
    input = Prompt.show_building_prompt
    return if input.to_a.empty?
    
    name, wall, roof, gwall, groof, bsf = input
    
    model.start_operation("Edit Building", true)
    # Set group properties
    objs.each do |obj|
      obj.set_attribute(DICTIONARY, :name, name)
      obj.set_attribute(DICTIONARY, :wall, wall)
      obj.set_attribute(DICTIONARY, :roof, roof)
      obj.set_attribute(DICTIONARY, :gwall, gwall)
      obj.set_attribute(DICTIONARY, :groof, groof)
      obj.set_attribute(DICTIONARY, :bsf, bsf)
    end
    model.selection.clear
    model.commit_operation
  end

  # Edit soil
  # @example
  #   Envimet::EnvimetInx.edit_soil
  def self.edit_soil
    model = Sketchup.active_model
    objs = initial_selection(model, "soil")
    return unless objs

    # Show the interface
    input = Prompt.show_soil_prompt
    
    return unless input
    
    model.start_operation("Edit Soil", true)
    # Set group properties
    objs.each do |obj|
      obj.set_attribute(DICTIONARY, :material, input)
    end
    model.selection.clear
    model.commit_operation
  end

  # Edit simple plant
  # @example
  #   Envimet::EnvimetInx.edit_simple_plant
  def self.edit_simple_plant
    model = Sketchup.active_model
    objs = initial_selection(model, "simple_plant")
    return unless objs

    # Show the interface
    input = Prompt.show_simple_plant_prompt
    
    return unless input
    
    model.start_operation("Edit Simple plant", true)
    # Set group properties
    objs.each do |obj|
      obj.set_attribute(DICTIONARY, :material, input)
    end
    model.selection.clear
    model.commit_operation
  end

  # Edit simple plant
  # @example
  #   Envimet::EnvimetInx.edit_plant3d
  def self.edit_plant3d
    model = Sketchup.active_model
    objs = initial_selection(model, "plant3d")
    return unless objs

    # Show the interface
    input = Prompt.show_plant3d_prompt
    
    return unless input
    
    model.start_operation("Edit Plant3d", true)
    # Set group properties
    objs.each do |obj|
      obj.set_attribute(DICTIONARY, :material, input)
    end
    model.selection.clear
    model.commit_operation
  end

  # Edit source
  # @example
  #   Envimet::EnvimetInx.edit_source
  def self.edit_source
    model = Sketchup.active_model
    objs = initial_selection(model, "source")
    return unless objs

    # Show the interface
    input = Prompt.show_source_prompt
    
    return unless input
    
    model.start_operation("Edit Source", true)
    # Set group properties
    objs.each do |obj|
      obj.set_attribute(DICTIONARY, :material, input)
    end
    model.selection.clear
    model.commit_operation
  end

  # Edit Grid rotation
  # @example
  #   Envimet::EnvimetInx.edit_grid_rotation
  def self.edit_grid_rotation
    model = Sketchup.active_model
    objs = initial_selection(model, "grid")
    return unless objs

    # Show the interface
    input = Prompt.show_rotation_prompt
    
    return unless input
    
    model.start_operation("Edit Grid rotation", true)
    # Set group properties
    objs.each do |obj|
      obj.set_attribute(DICTIONARY, :rotation, input)
    end
    model.selection.clear
    model.commit_operation
  end
end # end Envimet::EnvimetInx