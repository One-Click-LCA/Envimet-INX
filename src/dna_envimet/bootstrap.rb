module Envimet::EnvimetInx
  # load sources
  INSTALL_PATH = File.dirname(__FILE__)
  Sketchup.require 'dna_envimet/inx/grid'
  Sketchup.require 'dna_envimet/inx/pixel'
  Sketchup.require 'dna_envimet/inx/preparation'
  Sketchup.require 'dna_envimet/inx/trasformation'
  Sketchup.require 'dna_envimet/inx/location'
  Sketchup.require 'dna_envimet/inx/command/create_command'
  Sketchup.require 'dna_envimet/inx/command/edit_command'
  Sketchup.require 'dna_envimet/inx/command/inx_command'
  Sketchup.require 'dna_envimet/inx/command/utility_command'
  Sketchup.require 'dna_envimet/inx/inx'
  Sketchup.require 'dna_envimet/interface/grid_tool'
  Sketchup.require 'dna_envimet/interface/prompts'
  Sketchup.require 'dna_envimet/interface/inspector'
  Sketchup.require 'dna_envimet/interface/grid_observer'
  Sketchup.require 'dna_envimet/interface/selection_observer'
  Sketchup.require 'dna_envimet/interface/app_observer'
  Sketchup.require 'dna_envimet/interface/entities_observer'
  Sketchup.require 'dna_envimet/interface/visualizer'
  Sketchup.require 'dna_envimet/shared'
  Sketchup.require 'dna_envimet/ui_loader'
end
