module Envimet::EnvimetInx
  class AppObserver < Sketchup::AppObserver
    def onNewModel(model)
      observe_model(model)
      observe_entities(model)
    end

    def onOpenModel(model)
      observe_model(model)
      restart_grid_observers(model)
      observe_entities(model)
    end
    def expectsStartupModelNotifications
      return true
    end

    private

    def observe_model(model)
      model.selection.add_observer(Envimet::EnvimetInx::SelectionChangeObserver.new)
    end

    def observe_entities(model)
      model.entities.add_observer(Envimet::EnvimetInx::EntitiesObserver.new)
    end

    def restart_grid_observers(model)
      model = Sketchup.active_model
      grids = model.entities.grep(Sketchup::Group).select do |grp|
        grp.get_attribute(DICTIONARY, :type) == "grid"
      end
      return unless grids

      grids.each do |grd| 
        grd.add_observer(Envimet::EnvimetInx::GridObserver.new)
      end
    end
  end # end AppObserver
end # end Envimet::EnvimetInx