module Envimet::EnvimetInx
  class GridObserver < Sketchup::EntityObserver
    def onChangeEntity(entity)
      if entity.nil? || entity.deleted?
        return
      end

      # avoid scale for now
      rec_bounds = entity.get_attribute('ENVIMET', 'bounds')
      rec_z = entity.get_attribute('ENVIMET', 'min_z')
      if rec_bounds != entity.bounds.diagonal
        Sketchup.undo
        return
      end
      if rec_z != entity.bounds.min.z
        Sketchup.undo
        return
      end
    end
  end
end