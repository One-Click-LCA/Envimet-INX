# encoding: UTF-8
# ---------------------------------------------------------------------
# Envimet INX: A plugin for Sketchup to write model for ENVI_MET.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# @license GPL-3.0 <https://spdx.org/licenses/AGPL-3.0-only.html>
# --------------------------------------------------------------------
Sketchup.require 'sketchup'
Sketchup.require 'extensions'

module Envimet
  module EnvimetInx
    ENVIMET_VERSION = "2.1.1"

    unless file_loaded?(__FILE__)
      PLUGIN_ID = File.basename(__FILE__, ".rb")
      PLUGIN_DIR = File.join(File.dirname(__FILE__), PLUGIN_ID)

      ex = SketchupExtension.new("Envimet INX", "dna_envimet/bootstrap")

      ex.description = "ENVI_MET inx 2.5D plugin for SketchUp."
      ex.version = ENVIMET_VERSION
      ex.copyright   = "ENVI-met GmbH <info@envi-met.com>"
      ex.creator = "Antonello Di Nunzio <antonello.dinunzio@envi-met.com>"

      Sketchup.register_extension(ex, true)

      file_loaded(__FILE__)
    end
  end # end EnvimetInx
end # end Envimet
