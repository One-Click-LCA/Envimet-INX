module Envimet::EnvimetInx

  def self.activate_grid_tool
    Sketchup.active_model.select_tool(GridTool.new)
  end

  unless file_loaded?(__FILE__)
    # init preparation if UI loaded
    @@preparation = Preparation.new
    @@inspector = Inspector.new
    # Attach the observer
    Sketchup.add_observer(AppObserver.new)

    toolbar = UI::Toolbar.new "Envimet::EnvimetInx Extension"

    # create grid button
    cmd = UI::Command.new("Create Envimet Grid") do
      activate_grid_tool
    end
    cmd.tooltip = "Create Envimet Grid"
    cmd.status_bar_text = "Create Envimet Grid." \
    "\nFollow instructions in status bar."
    cmd.small_icon = cmd.large_icon = "res/icon/grid.png"
    toolbar = toolbar.add_item(cmd)

    # create building button
    cmd = UI::Command.new("Create Building") do 
      create_building
    end
    cmd.tooltip = "Create Building"
    cmd.status_bar_text = "Create buildings."
    cmd.small_icon = cmd.large_icon = "res/icon/building.png"
    toolbar = toolbar.add_item(cmd)

    # create soil button
    cmd = UI::Command.new("Create Soil") do 
      create_soil
    end
    cmd.tooltip = "Create Soil"
    cmd.status_bar_text = "Create soils."
    cmd.small_icon = cmd.large_icon = "res/icon/soil.png"
    toolbar = toolbar.add_item(cmd)

    # create simple plant button
    cmd = UI::Command.new("Create Simple plant") do 
      create_simple_plant
    end
    cmd.tooltip = "Create Simple plant"
    cmd.status_bar_text = "Create simple plants."
    cmd.small_icon = cmd.large_icon = "res/icon/plant2d.png"
    toolbar = toolbar.add_item(cmd)

    # create source
    cmd = UI::Command.new("Create Source") do 
      create_source
    end
    cmd.tooltip = "Create Source"
    cmd.status_bar_text = "Create sources."
    cmd.small_icon = cmd.large_icon = "res/icon/source.png"
    toolbar = toolbar.add_item(cmd)

    # create plant3d button
    cmd = UI::Command.new("Create Plant3d") do 
      create_plant3d
    end
    cmd.tooltip = "Create Plant3d"
    cmd.status_bar_text = "Create plant3ds."
    cmd.small_icon = cmd.large_icon = "res/icon/plant3d.png"
    toolbar = toolbar.add_item(cmd)

    # create terrain
    cmd = UI::Command.new("Create Terrain") do 
      create_terrain
    end
    cmd.tooltip = "Create Terrain"
    cmd.status_bar_text = "Create terrain (DEM)."
    cmd.small_icon = cmd.large_icon = "res/icon/terrain.png"
    toolbar = toolbar.add_item(cmd)

    # create receptor
    cmd = UI::Command.new("Create Receptor") do 
      create_receptor
    end
    cmd.tooltip = "Create Receptor"
    cmd.status_bar_text = "Create a receptor."
    cmd.small_icon = cmd.large_icon = "res/icon/receptor.png"
    toolbar = toolbar.add_item(cmd)

    toolbar.add_separator

    # Edit

    # edit grid rotation
    cmd = UI::Command.new("Edit Grid rotation") do
      edit_grid_rotation
    end
    cmd.tooltip = "Edit Grid rotation"
    cmd.status_bar_text = "Edit grid orientation (Envimet North)."
    cmd.small_icon = cmd.large_icon = "res/icon/rotation.png"
    toolbar = toolbar.add_item(cmd)

    # edit building
    cmd = UI::Command.new("Edit Building") do
      edit_building
    end
    cmd.tooltip = "Edit Building"
    cmd.status_bar_text = "Edit buildings metadata."
    cmd.small_icon = cmd.large_icon = "res/icon/edit_building.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Edit Soil") do
      edit_soil
    end
    cmd.tooltip = "Edit Soil"
    cmd.status_bar_text = "Edit soils metadata."
    cmd.small_icon = cmd.large_icon = "res/icon/edit_soil.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Edit Simple plant") do
      edit_simple_plant
    end
    cmd.tooltip = "Edit Simple plant"
    cmd.status_bar_text = "Edit simple plants metadata."
    cmd.small_icon = cmd.large_icon = "res/icon/edit_plant2d.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Edit Plant3d") do
      edit_plant3d
    end
    cmd.tooltip = "Edit Plant3d"
    cmd.status_bar_text = "Edit plant3d metadata."
    cmd.small_icon = cmd.large_icon = "res/icon/edit_plant3d.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Edit Source") do
      edit_source
    end
    cmd.tooltip = "Edit Source"
    cmd.status_bar_text = "Edit source metadata."
    cmd.small_icon = cmd.large_icon = "res/icon/edit_source.png"
    toolbar = toolbar.add_item(cmd)

    toolbar.add_separator

    cmd = UI::Command.new("Delete Envimet Object") do 
      delete_envimet_object 
    end
    cmd.tooltip = "Delete Envimet Object"
    cmd.status_bar_text = "Delete metadata of Envimet objects."
    cmd.small_icon = cmd.large_icon = "res/icon/delete.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Info Envimet Object") do 
      display_inspector
    end
    cmd.tooltip = "Info Envimet Object"
    cmd.status_bar_text = "Get information about Envimet objects."
    cmd.small_icon = cmd.large_icon = "res/icon/info.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Select by type") do 
      select_by_type
    end
    cmd.tooltip = "Search by type"
    cmd.status_bar_text = "Select Envimet objects by type."
    cmd.small_icon = cmd.large_icon = "res/icon/search.png"
    toolbar = toolbar.add_item(cmd)
    
    toolbar.add_separator
    
    # write inx button
    cmd = UI::Command.new("Write Envimet Model") do
      model = Sketchup.active_model
      model.start_operation("Save Inx", true)
      status = create_inx_model
      write_inx_file if status
      model.commit_operation
    end
    cmd.tooltip = "Write Envimet Model"
    cmd.status_bar_text = "Write envimet" \
    " model file on your machine."
    cmd.small_icon = cmd.large_icon = "res/icon/inx.png"
    toolbar = toolbar.add_item(cmd)
    
    toolbar.show
    
    file_loaded(__FILE__)
  end
end #Envimet::EnvimetInx
