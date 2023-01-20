module Envimet::EnvimetInx
  class EntityPreview < Struct.new(:geometries, 
    :colors)
    def initialize(geometries=[], colors=[]); 
      super 
    end

    def self.combine(collection)
      return unless collection.is_a? Array
      return if collection.empty?
      
      faces = collection.map { |elm| elm.geometries }
      colors = collection.map { |elm| elm.colors }

      EntityPreview.new(faces.reduce(&:concat), colors.reduce(&:concat))
    end
  end

  class Visualizer
    attr_accessor :entity_preview,
      :points
    
    COLORS = {
      "building" => Sketchup::Color.new(5, 103, 152),
      "soil" => Sketchup::Color.new(255, 170, 0),
      "simple_plant" => Sketchup::Color.new(168, 212, 11),
      "plant3d" => Sketchup::Color.new(54, 201, 65),
      "terrain" => Sketchup::Color.new(255, 0, 0),
      "source" => Sketchup::Color.new(11, 194, 255),
      "receptor" => Sketchup::Color.new(255, 0, 170)
    }

    def enable
      Sketchup.active_model.select_tool(self)
    end
    
    def initialize
      bld_prev = get_entities_data("building", COLORS["building"])
      sol_prev = get_entities_data("soil", COLORS["soil"])
      simple_plant_prev = get_entities_data("simple_plant", COLORS["simple_plant"])
      plant3d_prev = get_entities_data("plant3d", COLORS["plant3d"])
      terrain_prev = get_entities_data("terrain", COLORS["terrain"])
      source_prev = get_entities_data("source", COLORS["source"])
      receptor_prev = get_entities_data("receptor", COLORS["receptor"])

      self.points = []
      self.entity_preview = EntityPreview.combine([
        bld_prev,
        sol_prev,
        simple_plant_prev,
        plant3d_prev,
        terrain_prev,
        source_prev,
        receptor_prev
      ])

      unless entity_preview.geometries.empty?
        update_bbox
      end
    end

    def update_bbox
      entity_preview.geometries.each do |geo| 
        points.concat(geo)
      end
    end

    def activate
      update_ui
    end

    def deactivate(view)
      view.invalidate
    end

    def resume(view)
      update_ui
      view.invalidate
    end

    def suspend(view)
      view.invalidate
    end

    def onCancel(reason, view)
      reset_tool
      view.invalidate
    end

    def onMouseMove(flags, x, y, view)
      view.invalidate
    end

    CURSOR = UI.create_cursor(
      File.join(PLUGIN_DIR, 
      "res/icon/visualize.png"), 0, 0)
    
    def onSetCursor
      UI.set_cursor(CURSOR)
    end

    def draw(view)
      draw_preview3d(view)
      draw_legend(view)
    end

    def getExtents
      bounds = Geom::BoundingBox.new
      unless entity_preview.geometries.empty?
        bounds.add(points)
      end
      bounds
    end

    private

    def get_entities_data(type, color)
      ents = Envimet::EnvimetInx.collect_envimet_type(type)
      ent_faces = Envimet::EnvimetInx.walk_faces(ents)
      ent_colors = ent_faces.size > 0 ? [color] * ent_faces.size : []
      EntityPreview.new(ent_faces, ent_colors)
    end

    def draw_legend(view)
      labels = [
        "building",
        "soil",
        "simple_plant",
        "plant3d",
        "terrain",
        "source",
        "receptor"
      ]

      y_pos = Array.new(labels.size) { |e| e *= 40 }
      
      view.drawing_color = "white"
      view.draw2d(GL_POLYGON, [[0, 0], 
        [180, 0], 
        [180, y_pos.max + 40], 
        [0, y_pos.max + 40]])

      labels.each_with_index do |t, i|
        view.draw_text([10, y_pos[i]], 
        t.upcase, { :size => 16, 
          :color => COLORS[t],
          :font => "Arial",
          :bold => true})
      end
    end

    def update_ui
    end

    def reset_tool
      update_ui
    end

    def draw_preview3d(view)
      return if entity_preview.geometries.empty?
      entity_preview.geometries.each_with_index do |geo, i|
        view.drawing_color = entity_preview.colors[i]
        view.draw(GL_POLYGON, *geo)
      end
    end

  end # class Visualizer
end # end Envimet::EnvimetInx