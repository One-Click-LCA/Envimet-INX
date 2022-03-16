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
    cmd.status_bar_text = "Use this command to create Envimet Grid." \
    "\nFollow instructions in status bar."
    cmd.small_icon = cmd.large_icon = "res/icon/grid.png"
    toolbar = toolbar.add_item(cmd)

    # create building button
    cmd = UI::Command.new("Create Building") do 
      create_building
    end
    cmd.tooltip = "Create Building"
    cmd.status_bar_text = "Use this command to create buildings." \
    "\n1. Select skp objects\n2. Click on this command."
    cmd.small_icon = cmd.large_icon = "res/icon/building.png"
    toolbar = toolbar.add_item(cmd)

    # create soil button
    cmd = UI::Command.new("Create Soil") do 
      create_soil
    end
    cmd.tooltip = "Create Soil"
    cmd.status_bar_text = "Use this command to create soils." \
    "\n1. Select skp components\n2. Click on this command.\n"
    ""
    cmd.small_icon = cmd.large_icon = "res/icon/soil.png"
    toolbar = toolbar.add_item(cmd)

    # create simple plant button
    cmd = UI::Command.new("Create Simple plant") do 
      create_simple_plant
    end
    cmd.tooltip = "Create Simple plant"
    cmd.status_bar_text = "Use this command to create simple plants." \
    "\n1. Select skp components\n2. Click on this command.\n"
    ""
    cmd.small_icon = cmd.large_icon = "res/icon/plant2d.png"
    toolbar = toolbar.add_item(cmd)

    # create source
    cmd = UI::Command.new("Create Source") do 
      create_source
    end
    cmd.tooltip = "Create Source"
    cmd.status_bar_text = "Use this command to create sources." \
    "\n1. Select skp components\n2. Click on this command.\n"
    ""
    cmd.small_icon = cmd.large_icon = "res/icon/source.png"
    toolbar = toolbar.add_item(cmd)

    # create plant3d button
    cmd = UI::Command.new("Create Plant3d") do 
      create_plant3d
    end
    cmd.tooltip = "Create Plant3d"
    cmd.status_bar_text = "Use this command to create plant3ds." \
    "\n1. Select skp components\n2. Click on this command.\n"
    ""
    cmd.small_icon = cmd.large_icon = "res/icon/plant3d.png"
    toolbar = toolbar.add_item(cmd)

    # create terrain
    cmd = UI::Command.new("Create Terrain") do 
      create_terrain
    end
    cmd.tooltip = "Create Terrain"
    cmd.status_bar_text = "Use this command to create terrain (DEM)." \
    "\n1. Select skp components\n2. Click on this command.\n"
    ""
    cmd.small_icon = cmd.large_icon = "res/icon/terrain.png"
    toolbar = toolbar.add_item(cmd)

    # create receptor
    cmd = UI::Command.new("Create Receptor") do 
      create_receptor
    end
    cmd.tooltip = "Create Receptor"
    cmd.status_bar_text = "Use this command to create a receptor." \
    "\n1. Select just one skp component\n2. Click on this command.\n"
    ""
    cmd.small_icon = cmd.large_icon = "res/icon/receptor.png"
    toolbar = toolbar.add_item(cmd)

    toolbar.add_separator

    # Edit

    # edit grid rotation
    cmd = UI::Command.new("Edit Grid rotation") do
      edit_grid_rotation
    end
    cmd.tooltip = "Edit Grid rotation"
    cmd.status_bar_text = "Use this command to edit grid rotation." \
    "\n1. Select groups\n2. Click on this command.\nIt accepts only" \
    " Envimet::EnvimetInx entities and it filters grids."
    cmd.small_icon = cmd.large_icon = "res/icon/rotation.png"
    toolbar = toolbar.add_item(cmd)

    # edit building
    cmd = UI::Command.new("Edit Building") do
      edit_building
    end
    cmd.tooltip = "Edit Building"
    cmd.status_bar_text = "Use this command to edit buildings." \
    "\n1. Select groups\n2. Click on this command.\nIt accepts only" \
    " Envimet::EnvimetInx entities and it filters buildings."
    cmd.small_icon = cmd.large_icon = "res/icon/edit_building.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Edit Soil") do
      edit_soil
    end
    cmd.tooltip = "Edit Soil"
    cmd.status_bar_text = "Use this command to edit soils." \
    "\n1. Select groups\n2. Click on this command.\nIt accepts only" \
    " Envimet::EnvimetInx entities and it filters soils."
    cmd.small_icon = cmd.large_icon = "res/icon/edit_soil.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Edit Simple plant") do
      edit_simple_plant
    end
    cmd.tooltip = "Edit Simple plant"
    cmd.status_bar_text = "Use this command to edit simple plants." \
    "\n1. Select groups\n2. Click on this command.\nIt accepts only" \
    " Envimet::EnvimetInx entities and it filters simple plants."
    cmd.small_icon = cmd.large_icon = "res/icon/edit_plant2d.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Edit Plant3d") do
      edit_plant3d
    end
    cmd.tooltip = "Edit Plant3d"
    cmd.status_bar_text = "Use this command to edit plant3d." \
    "\n1. Select groups\n2. Click on this command.\nIt accepts only" \
    " Envimet::EnvimetInx entities and it filters plant3d."
    cmd.small_icon = cmd.large_icon = "res/icon/edit_plant3d.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Edit Source") do
      edit_source
    end
    cmd.tooltip = "Edit Source"
    cmd.status_bar_text = "Use this command to edit source." \
    "\n1. Select groups\n2. Click on this command.\nIt accepts only" \
    " Envimet::EnvimetInx entities and it filters source."
    cmd.small_icon = cmd.large_icon = "res/icon/edit_source.png"
    toolbar = toolbar.add_item(cmd)

    toolbar.add_separator

    cmd = UI::Command.new("Delete Envimet Object") do 
      delete_envimet_object 
    end
    cmd.tooltip = "Delete Envimet Object"
    cmd.status_bar_text = "Use this command to delete " \
    "Envimet objects.\nOnly Envimet object will be" \
    " deleted and not Sketchup geometries. Except envimet grids." \
    "\n1. Select envimet object to delete\n2. Click on this command."
    cmd.small_icon = cmd.large_icon = "res/icon/delete.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Info Envimet Object") do 
      display_inspector
    end
    cmd.tooltip = "Info Envimet Object"
    cmd.status_bar_text = "Use this command to get information" \
    "about Envimet objects.\nYou can also use it to check if " \
    "Envimet objects are active (see. SKPINX)."
    cmd.small_icon = cmd.large_icon = "res/icon/info.png"
    toolbar = toolbar.add_item(cmd)

    cmd = UI::Command.new("Select by type") do 
      select_by_type
    end
    cmd.tooltip = "Search by type"
    cmd.status_bar_text = "Use this command to get information" \
    "about Envimet objects.\nYou can also use it to check if " \
    "Envimet objects are active (see. SKPINX)."
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
    cmd.status_bar_text = "Use this command to write envimet" \
    " model file on your machine."
    cmd.small_icon = cmd.large_icon = "res/icon/inx.png"
    toolbar = toolbar.add_item(cmd)
    
    toolbar.show
    
    file_loaded(__FILE__)
  end
end #Envimet::EnvimetInx
