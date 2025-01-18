module Envimet::EnvimetInx
  class GridTool
    def activate
      @mouse_ip = Sketchup::InputPoint.new
      @picked_first_ip = Sketchup::InputPoint.new
      @boundary_box = nil

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
      if picked_first_point?
        @mouse_ip.pick(view, x, y, @picked_first_ip)
      else
        @mouse_ip.pick(view, x, y)
      end
      view.tooltip = @mouse_ip.tooltip if @mouse_ip.valid?
      view.invalidate
    end

    def onLButtonDown(flags, x, y, view)
      if picked_first_point?

        set_bbox_from_points(picked_points)

        selection = Prompt.get_grid_selection
        if selection.nil?
          update_ui
          view.invalidate
          return
        end

        Envimet::EnvimetInx.create_grid(@boundary_box,
          selection)

        reset_tool
      else
        @picked_first_ip.copy!(@mouse_ip)
      end

      update_ui
      view.invalidate
    end

    CURSOR_POINT = UI.create_cursor(File.join(PLUGIN_DIR,
      "res/x.svg"), 0, 0)

    def onSetCursor
      UI.set_cursor(CURSOR_POINT)
    end

    def draw(view)
      draw_preview(view)
      @mouse_ip.draw(view) if @mouse_ip.display?
    end

    def getExtents
      bounds = Geom::BoundingBox.new
      bounds.add(picked_points) if picked_points
      bounds
    end

    private

    def update_ui
      if picked_first_point?
        Sketchup.status_text = 'Select end point.'
      else
        Sketchup.status_text = 'Select start point.'
      end
    end

    def reset_tool
      @picked_first_ip.clear
      update_ui
    end

    def picked_first_point?
      @picked_first_ip.valid?
    end

    def picked_points
      points = []
      points << @picked_first_ip.position if picked_first_point?
      points << @mouse_ip.position if @mouse_ip.valid?
      points
    end

    def draw_preview(view)
      points = picked_points
      return unless points.size == 2

      if points.size == 2
        view.drawing_color = Sketchup::Color.new(255, 0, 0, 64)
        view.line_width = 2
        view.line_stipple = "_"
        pt1, pt2 = points
        view.draw(GL_LINE_LOOP, [[pt1.x, pt1.y],
          [pt2.x, pt1.y], [pt2.x, pt2.y], [pt1.x, pt2.y]])
      end
    end

    def set_bbox_from_points(pts)
      boundingbox = Geom::BoundingBox.new
      pts.each { |pt| boundingbox.add(pt) }
      @boundary_box = boundingbox
    end
  end # end GridTool
end # end Envimet::EnvimetInx
