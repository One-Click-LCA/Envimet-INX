module Envimet::EnvimetInx
  class EntitiesObserver < Sketchup::EntitiesObserver 
    def onElementAdded(entities, entity)
      # add grid observer here
      if entity.is_a?(Sketchup::Group) &&
        entity.get_attribute(DICTIONARY, :type) == "grid"

        entity.add_observer(Envimet::EnvimetInx::GridObserver.new)
      end
    end
  end
end # end Envimet::EnvimetInx