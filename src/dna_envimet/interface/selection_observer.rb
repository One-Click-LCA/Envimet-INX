module Envimet::EnvimetInx
  class SelectionChangeObserver < Sketchup::SelectionObserver
    def onSelectionAdded(selection, entity)
      on_selection_change(selection)
    end
    def onSelectionBulkChange(selection)
      on_selection_change(selection)
    end
    def onSelectionCleared(selection)
      on_selection_change(selection)
    end
    def onSelectionRemoved(selection, entity)
      on_selection_change(selection)
    end
    def onSelectedRemoved(selection, entity)
      on_selection_change(selection)
    end

    private

    def on_selection_change(selection)
      return if Envimet::EnvimetInx.inspector.nil?
      values, total = Envimet::EnvimetInx.get_envimet_entity_info
      Envimet::EnvimetInx.inspector.dialog.execute_script(
        "insertData(\"#{values}\");")
      Envimet::EnvimetInx.inspector.dialog.execute_script(
        "count(\"#{total}\");")
    end
  end # end SelectionChangeObserver
end # end Envimet::EnvimetInx