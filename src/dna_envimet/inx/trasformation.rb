module Envimet::EnvimetInx
  UPPER_LIMIT = 1_000_000
  
  class Intersection
    attr_reader :intersection_pts, :intersection_grp

    def initialize
      @intersection_pts = []
      @intersection_grp = []
    end

    # Because Envimet INX is not a standard XML
    # workaround instead of a newline
    def get_envimet_matrix(matrix)
      text = "§"
      matrix.reverse.each do |column|
        text << column.join(",")
        text += "§"
      end
      text
    end

    
    def get_matrix(intersection, grid, matrix, text=false)
      y_axis = grid.other_info[:y_axis]
      x_axis = grid.other_info[:x_axis]

      rounded_x_axis = x_axis.map { |num| num.round(3) }
      rounded_y_axis = y_axis.map { |num| num.round(3) }

      intersection.each do |vec|
        index_x = rounded_x_axis.index(vec[0])
        index_y = rounded_y_axis.index(vec[1])
        if text
          matrix[index_y][index_x] = vec[2]
        else
          matrix[index_y][index_x] = vec[2].to_m.round(0)
        end
      end
      matrix
    end

    def get_group_global_min_max(group)
      boundingbox = group.local_bounds
      min_pt = boundingbox.min.transform(group.transformation) # to global
      max_pt = boundingbox.max.transform(group.transformation) # to global
      return min_pt, max_pt
    end

    def filter_array_by_limit(values, lower_limit, upper_limit)
      arr = values.dup
      arr.keep_if { |num| num >= lower_limit && num <= upper_limit }
    end
    
    def get_inteserction(grid, group, type)
      pts, params = [], []

      min, max = get_group_global_min_max(group)

      y_axis = grid.other_info[:y_axis]
      x_axis = grid.other_info[:x_axis]
      x_axis = filter_array_by_limit(x_axis, min.x, max.x)
      y_axis = filter_array_by_limit(y_axis, min.y, max.y)

      y_axis.each do |j|
        x_axis.each do |i|
          # raycast begin
          raycast(i, j, UPPER_LIMIT)
          pts << [@intersection_pts.first, @intersection_pts.last]
          par = [nil]
          unless @intersection_grp.first.nil?
            x = @intersection_pts.first.x
            y = @intersection_pts.first.y
            z = from_type(type)
            par = [[x, y, z]]
          end
          params << par

          @intersection_pts = []
          @intersection_grp = []
        end
      end

      return pts, params
    end


    private

    def from_type(type)
      case type
        when "building" then @intersection_grp.first.get_attribute("ENVIMET", :ID)
        when "soil" then @intersection_grp.first.get_attribute("ENVIMET", :material)
        when "simple_plant" then @intersection_grp.first.get_attribute("ENVIMET", :material)
        when "source" then @intersection_grp.first.get_attribute("ENVIMET", :material)
        when "terrain" then @intersection_grp.first.get_attribute("ENVIMET", " ") # placeholder
      else
        nil
      end
    end


    def raycast(x_value, y_value, z_value)
      model = Sketchup.active_model
      ray = [Geom::Point3d.new(x_value, y_value, z_value), 
        Geom::Vector3d.new(0, 0, -1)]
      items = model.raytest(ray, true)

      if items.nil?
        return
      else
        # iterate groups
        groups = items.last.grep(Sketchup::Group)

        unless groups.empty?
          @intersection_pts << items.first
          @intersection_grp << groups.first
          raycast(x_value, y_value, items.first.z)
        end
      end
    end

  end # end Intersection
end # end Envimet::EnvimetInx
