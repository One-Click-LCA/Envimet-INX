module Envimet::EnvimetInx
  module Geometry
    class Grid

      FIRST_CELLS = 5
      GRID_TYPE = { 
        "1" => :equidistant, 
        "2" => :telescope, 
        "3" => :combined 
      }

      attr_reader :dim_x, :dim_y, :dim_z
      attr_accessor :other_info

      def initialize(bbox, configuration)

        values = {
            start_telescope_height: nil,
            telescope: nil
        }

        values.merge!(configuration)
        @other_info = values

        @dim_x = other_info[:dim_x].m
        @dim_y = other_info[:dim_y].m
        @dim_z = other_info[:dim_z].m

        update_sequence(bbox)
      end
      
      
      def self.base_matrix_2d(num_x, 
        num_y, 
        item = nil)
        column = []
        num_y.times do
          row = []
          num_x.times do
            row << item
          end
          column << row
        end
        
        column
      end


      def update_sequence(bbox)
        # set the boundary, sequence and grid
        set_grid_from_bbox(bbox)
        set_sequence
        set_x_axis
        set_y_axis
      end
      
      private
      
      def set_x_axis
        x_axis = []
        other_info[:num_x].times { |i| x_axis << \
          (i * dim_x) + other_info[:min_x] }
          other_info[:x_axis] = x_axis
        end
        
        def set_y_axis
          y_axis = []
          other_info[:num_y].times { |j| y_axis << \
            (j * dim_y) + other_info[:min_y] }
            other_info[:y_axis] = y_axis
          end
          
          def set_grid_from_bbox(bbox)
            min_x, min_y, min_z = bbox.min.to_a
            max_x, max_y, max_z = bbox.max.to_a
            
            domain_x = max_x - min_x
            domain_y = max_y - min_y
            
            num_x = (domain_x / dim_x).round
            num_y = (domain_y / dim_y).round
            
            max_x = min_x + (num_x * dim_x)
            max_y = min_y + (num_y * dim_y)
            
            other_info[:num_x] = num_x
            other_info[:num_y] = num_y
            
            other_info[:min_x] = min_x
            other_info[:min_y] = min_y
            
            other_info[:max_x] = max_x
            other_info[:max_y] = max_y
          end
          

      def set_sequence
        # based on type get the sequence
        case (other_info[:grid_type])
        when GRID_TYPE["1"]
          other_info[:sequence] = get_equidistant_sequence(
            other_info[:num_z]).map(&:to_f)
        when GRID_TYPE["2"]
          other_info[:sequence] = get_telescope_sequence(
            other_info[:num_z]).map(&:to_f)
        when GRID_TYPE["3"]
          other_info[:sequence] = get_combined_sequence(
            other_info[:num_z]).map(&:to_f)
        else
          other_info[:sequence] = get_equidistant_sequence(
            other_info[:num_z]).map(&:to_f)
        end

        other_info[:height] = other_info[:sequence].sum
      end

      # Sequence z
      def get_equidistant_sequence(num_z_cell)
        base_cell = self.dim_z / FIRST_CELLS
        cell = self.dim_z
        sequence = []
        num_z_cell.times { |k| sequence[k] = (k < 5) ? base_cell : cell }
        sequence
      end

      def get_telescope_sequence(num_z_cell)
        cell = self.dim_z
        sequence = []
        val = cell

        num_z_cell.times do |k|
          if (val * k < other_info[:start_telescope_height])
            sequence[k] = cell
          else
            sequence[k] = val + (val * other_info[:telescope] / 100)
            val = sequence[k]
          end
        end

        sequence
      end

      def get_combined_sequence(num_z_cell)
        equidistant_sequence = get_equidistant_sequence(FIRST_CELLS)
        telescopic_sequence = get_telescope_sequence(num_z_cell)
        telescopic_sequence.shift

        sequence = equidistant_sequence + telescopic_sequence

        sequence
      end
    end # end Grid

    def self.get_grid_min_pt(grid)
      Geom::Point3d.new(grid.other_info[:min_x] - grid.dim_x / 2, 
        grid.other_info[:min_y] - grid.dim_y / 2, 0)
    end
  
    def self.get_grid_max_pt(grid)
      Geom::Point3d.new(grid.other_info[:max_x] + grid.dim_x / 2, 
        grid.other_info[:max_y] + grid.dim_y / 2, 0)
    end

    def self.get_boundary_extension(pt_min, pt_max, height)
      model = Sketchup.active_model
      entities = model.active_entities

      pt1 = pt_min
      pt8 = Geom::Point3d.new(pt_max.x, pt_max.y, height)

      pt2 = Geom::Point3d.new(pt8.x, pt1.y, pt1.z)
      pt3 = Geom::Point3d.new(pt1.x, pt1.y, pt8.z)
      pt4 = Geom::Point3d.new(pt8.x, pt1.y, pt8.z)

      pt5 = Geom::Point3d.new(pt1.x, pt8.y, pt1.z)
      pt6 = Geom::Point3d.new(pt8.x, pt8.y, pt1.z)
      pt7 = Geom::Point3d.new(pt1.x, pt8.y, pt8.z)

      points = [pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8]

      combination = points.combination(2).to_a

      lines = []
      combination.each { |pts| lines << entities.add_line(pts[0], pts[1]) \
        if self.point_comparison_validation(pts[0], pts[1]) }

      return lines
    end

    def self.point_comparison_validation(pt1, pt2)
      (pt1.x == pt2.x && pt1.y == pt2.y) || \
      (pt1.x == pt2.x && pt1.z == pt2.z) || \
      (pt1.y == pt2.y && pt1.z == pt2.z)
    end

    def self.get_base_grid(grid)
      dist_x = grid.dim_x / 2
      dist_y = grid.dim_y / 2

      sequence_y = grid.other_info[:y_axis].dup.map { |n| n + dist_y }
      sequence_x = grid.other_info[:x_axis].dup.map { |n| n + dist_x }

      lines = []
      entities = Sketchup.active_model.entities
      sequence_y.each { |dist| lines << entities.add_cline(
        Geom::Point3d.new(grid.other_info[:min_x] - dist_x, dist, 0), 
        Geom::Point3d.new(grid.other_info[:x_axis].last + dist_x*3, dist, 0)) }
      sequence_x.each { |dist| lines << entities.add_cline(
        Geom::Point3d.new(dist, grid.other_info[:min_y] - dist_y, 0), 
        Geom::Point3d.new(dist, grid.other_info[:y_axis].last + dist_y*3, 0)) }
      lines
    end

    def self.generate_grid_group(grid)
      pt_min = get_grid_min_pt(grid)
      pt_max = get_grid_max_pt(grid)

      line_extension = self.get_boundary_extension(pt_min, 
        pt_max, grid.other_info[:height])

      group = Sketchup.active_model.entities.add_group(line_extension,
        get_base_grid(grid))

      # save info
      group.set_attribute(DICTIONARY, :type, "grid")
      group.set_attribute(DICTIONARY, :grid_type, 
        grid.other_info[:grid_type].to_s)
      group.set_attribute(DICTIONARY, :num_z, grid.other_info[:num_z])
      group.set_attribute(DICTIONARY, :dim_x, grid.dim_x.to_m)
      group.set_attribute(DICTIONARY, :dim_y, grid.dim_y.to_m)
      group.set_attribute(DICTIONARY, :dim_z, grid.dim_z.to_m)
      group.set_attribute(DICTIONARY, :bounds, group.bounds.diagonal)
      group.set_attribute(DICTIONARY, :min_z, group.bounds.min.z)
      group.set_attribute(DICTIONARY, :telescope, 
        grid.other_info[:telescope])
        group.set_attribute(DICTIONARY, :rotation, 
          grid.other_info[:rotation])
      group.set_attribute(DICTIONARY, :start_telescope_height, 
        grid.other_info[:start_telescope_height])
    end

    def self.create_grid_from_group(group)
      others = {}
      # save specific info
      attrdicts = group.attribute_dictionaries
      dict = attrdicts[DICTIONARY]
      return if dict.nil?

      dict.each_pair do |k, v|
        others[k.to_sym] = v
      end
      bbox = group.bounds

      # Shift to get centroid
      dim_x = group.get_attribute(DICTIONARY, :dim_x)
      dim_y = group.get_attribute(DICTIONARY, :dim_y)

      min_pt = Geom::Point3d.new(bbox.min.x + dim_x / 2, 
        bbox.min.y + dim_y / 2, 0)
      max_pt =  Geom::Point3d.new(bbox.max.x - dim_x / 2, 
        bbox.max.y - dim_y / 2, 0)

      bbox = Geom::BoundingBox.new
      bbox.add([min_pt, max_pt])
      
      # create a new grid
      grid = Grid.new(bbox, others)

      grid
    end

  end # end Geometry
end # Envimet::EnvimetInx
