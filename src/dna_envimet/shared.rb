module Envimet::EnvimetInx
  Sketchup.require "JSON" unless defined? JSON

  DICTIONARY = "ENVIMET"

  # Get all faces from entities.
  # @example
  #   faces = Envimet::EnvimetInx.walk_faces(entities)
  def self.walk_faces( entities, transformation = Geom::Transformation.new )
    faces = []
    entities.each do |e|
      if e.is_a?( Sketchup::Face )
        faces << e.outer_loop.vertices.map do |vertex|
          vertex.position.transform(transformation)
        end
      elsif e.is_a?( Sketchup::Group )
        faces.concat( walk_faces( e.entities, transformation *
          e.transformation ) )
      elsif e.is_a?( Sketchup::ComponentInstance )
        faces.concat( walk_faces( e.definition.entities, transformation *
          e.transformation ) )
      end
    end
    
    faces
  end

  # Read configuration settings and return them as Ruby Hash.
  # @example
  #   Envimet::EnvimetInx.load_settings
  def self.load_settings(json_file = "envimet-materials.json")
    file = File.read(File.join(INSTALL_PATH, json_file))
    JSON.parse(file)
  end

  # Get preparation instance
  # @example
  #   Envimet::EnvimetInx.preparation
  def self.preparation
    @@preparation
  end

  def self.inspector
    @@inspector
  end

  # Get envimet group from current skp model
  # @example
  #   Envimet::EnvimetInx.collect_envimet_type "building"
  def self.collect_envimet_type(type)
    ents = Sketchup.active_model.entities
    ents.grep(Sketchup::Group).select do |grp| 
      grp.get_attribute(DICTIONARY, :type) == type
    end
  end

  # Hide all SketchUp Entities from Model but those that are in the array
  # @param arr [Array] List of entities to show
  # @return [Array] of entities that were hidden
  # @example
  #   hidden_entities = Envimet::EnvimetInx.hide_all_except(arr)
  # show entities back / alternatively you can just call Sketchup.undo 
  # if no changes are made to SKP model
  # @example
  #   hidden_entities.each { |e| e.visible true false }
  def self.hide_all_except(arr)
    model = Sketchup.active_model
    ents = model.entities.reject { |e| arr.include?(e) }
    ents_to_hide = ents.select { |e| e.visible? }
    ents_to_hide.each { |e| e.visible = false }
    return ents_to_hide
  end

  # Get buiding group by uuid
  # @return [Array] of building groups
  # @example
  #   grp = Envimet::EnvimetInx.get_building_grp_by_uuid id
  def self.get_building_grp_by_uuid(uuid)
    uuid_to_search = uuid.kind_of?(Array) ? uuid : [uuid]

    ents = Sketchup.active_model.entities
    buildings = ents.grep(Sketchup::Group).select do |grp|
      grp.get_attribute(DICTIONARY, :type) == "building" && \
      uuid_to_search.include?(grp.get_attribute(DICTIONARY, :ID))
    end

    buildings
  end
end
