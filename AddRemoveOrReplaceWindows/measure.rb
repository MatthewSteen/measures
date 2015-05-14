# start the measure
class AddRemoveOrReplaceWindows < OpenStudio::Ruleset::ModelUserScript

  # define the name that the user will see
  def name
    return "Add Remove Or Replace Windows"
  end

  # define the arguments that the user will enter
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    function_choices = OpenStudio::StringVector.new
    function_choices << "Add"
    function_choices << "Remove"
    function_choices << "Replace"
    function = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("function", function_choices, true)
    function.setDisplayName("Function")
    args << function

    facade_choices = OpenStudio::StringVector.new
    facade_choices << "All"
    facade_choices << "North"
    facade_choices << "East"
    facade_choices << "South"
    facade_choices << "West"
    facade = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("facade", facade_choices, true)
    facade.setDisplayName("Facade")
    args << facade

    wwr = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("wwr", true)
    wwr.setDisplayName("Window to Wall Ratio (fraction)")
    wwr.setDefaultValue(0.4)
    args << wwr

    offset = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("offset", true)
    offset.setDisplayName("Height Offset from Floor (in)")
    offset.setDefaultValue(30.0)
    args << offset

    return args

  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    super(model, runner, user_arguments)

    # use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign user inputs to variables
    function = runner.getStringArgumentValue("function", user_arguments)
    facade = runner.getStringArgumentValue("facade", user_arguments)
    wwr = runner.getDoubleArgumentValue("wwr", user_arguments)
    offset = runner.getDoubleArgumentValue("offset", user_arguments)

    # check arguments for reasonableness
    if wwr <= 0 or wwr >= 1
      runner.registerError("Window to wall ratio must be > 0 and < 1.")
      return false
    end

    if offset <= 0
      runner.registerError("Height offset must be > 0.")
      return false
    elsif offset > 360
      runner.registerWarning("Height offset seems unusually high.")
    elsif offset > 9999
      runner.registerError("Height offset is above the limit for sill height.")
      return false
    end

    #setup OpenStudio units that we will need
    unit_offset_ip = OpenStudio::createUnit("ft").get
    unit_offset_si = OpenStudio::createUnit("m").get
    unit_area_ip = OpenStudio::createUnit("ft^2").get
    unit_area_si = OpenStudio::createUnit("m^2").get
    unit_cost_per_area_ip = OpenStudio::createUnit("1/ft^2").get #$/ft^2 does not work
    unit_cost_per_area_si = OpenStudio::createUnit("1/m^2").get

    #define starting units
    offset_ip = OpenStudio::Quantity.new(offset/12, unit_offset_ip)

    #unit conversion
    offset_si = OpenStudio.convert(offset_ip, unit_offset_si).get

    # initialize variables
    add_replace_count = 0
    remove_count =0
    starting_gross_ext_wall_area = 0.0 #includes windows and doors
    starting_ext_window_area = 0.0
    final_gross_ext_wall_area = 0.0 #includes windows and doors
    final_ext_window_area = 0.0

    #flag for not applicable
    ext_walls = false
    windows_added = false

    #flag to track notifications of zone multipliers
    space_warning_issued = []

    #flag to track warning for new windows without construction
    empty_const_warning = false

    #calculate initial envelope cost as negative value
    envelope_cost = 0
    constructions = model.getConstructions
    constructions.each do |construction|
      const_lccs = construction.lifeCycleCosts
      const_lccs.each do |const_lcc|
        if const_lcc.category == "Construction"
          envelope_cost += const_lcc.totalCost * -1
        end
      end
    end

    # get model objects
    surfaces = model.getSurfaces

    # add remove or replace windows
    # loop through surfaces finding exterior walls with selected orientation
    surfaces.each do |s|

      subsurfaces = s.subSurfaces

      next if not s.surfaceType == "Wall"
      next if not s.outsideBoundaryCondition == "Outdoors"
      next if subsurfaces.size > 0 and function == "Add"

      if s.space.empty?
        runner.registerWarning("surface doesn't have a parent space and won't be included in the measure: #{s.name}")
        next
      end

      if not facade == "All"

        # calculate the absolute azimuth to determine orientation
        absolute_azimuth = OpenStudio.convert(s.azimuth,"rad","deg").get + s.space.get.directionofRelativeNorth + model.getBuilding.northAxis
        until absolute_azimuth < 360.0
          absolute_azimuth = absolute_azimuth - 360.0
        end

        if facade == "North"
          next if not (absolute_azimuth >= 315.0 or absolute_azimuth < 45.0)
        elsif facade == "East"
          next if not (absolute_azimuth >= 45.0 and absolute_azimuth < 135.0)
        elsif facade == "South"
          next if not (absolute_azimuth >= 135.0 and absolute_azimuth < 225.0)
        elsif facade == "West"
          next if not (absolute_azimuth >= 225.0 and absolute_azimuth < 315.0)
        else
          runner.registerError("unexpected value of facade:" + facade)
          return false
        end

      end

      ext_walls = true

      # calculate surface area adjusting for zone multiplier
      space = s.space

      if not space.empty?
        zone = space.get.thermalZone
      end

      if not zone.empty?
        zone_mult = zone.get.multiplier
        if zone_mult > 1 and not space_warning_issued.include?(space.get.name.to_s)
          runner.registerInfo("Adjusting area calculations for space #{space.get.name.to_s} in zone #{zone.get.name.to_s} due to zone multiplier #{zone_mult}.")
          space_warning_issued << space.get.name.to_s
        end
      else
        zone_mult = 1 #space is not in a thermal zone
        runner.registerWarning("Space isn't in a thermal zone and won't be included in the simulation. Windows will still be altered with an assumed zone multiplier of 1: #{space.get.name.to_s}")
      end

      surface_gross_area = s.grossArea * zone_mult

      # loop through subsurfaces and add area including multiplier
      ext_window_area = 0

      subsurfaces.each do |ss|
        ext_window_area = ext_window_area + ss.grossArea * ss.multiplier * zone_mult
        if ss.multiplier > 1
          runner.registerInfo("Adjusting area calculations for subsurface #{ss.name} in space #{space.get.name.to_s} due to subsurface multiplier #{ss.multiplier}.")
        end
      end

      starting_gross_ext_wall_area += surface_gross_area
      starting_ext_window_area += ext_window_area

      if function == "Remove"

        subsurfaces.each do |ss|
          ss.remove
          remove_count += 1
        end

      else #function == "Add" or function == "Replace"

        new_window = s.setWindowToWallRatio(wwr, offset_si.value, true)
        if new_window.empty?
          runner.registerWarning("The requested window to wall ratio was too large, fenestration was not altered for surface: #{s.name}")
        else
          windows_added = true
          #warn user if resulting window doesn"t have a construction, as it will result in failed simulation. In the future may use logic from starting windows to apply construction to new window.
          if new_window.get.construction.empty? and empty_const_warning == false
            runner.registerWarning("One or more resulting windows do not have constructions. This script is intended to be used with models using construction sets versus hard assigned constructions.")
            empty_const_warning = true
          end
        end

        add_replace_count += 1

      end

    end #add remove or replace windows

    # report initial condition
    # wwr does not currently account for either subsurface or zone multipliers
    starting_wwr = sprintf("%.02f",(starting_ext_window_area/starting_gross_ext_wall_area))
    runner.registerInitialCondition("window to wall ratio for #{facade} exterior walls = #{starting_wwr}")

    if not ext_walls
      runner.registerAsNotApplicable("The model doesn't have exterior walls and was not altered.")
      return true
    elsif not windows_added and not function == "Remove"
      runner.registerAsNotApplicable("The model does have exterior walls, but no windows could be added with the requested window to wall ratio.")
      return true
    end

    # report final condition
    # wwr does not currently account for either subsurface or zone multipliers
    surfaces.each do |s|
      next if not s.surfaceType == "Wall"
      next if not s.outsideBoundaryCondition == "Outdoors"
      if s.space.empty?
        runner.registerWarning("Surface doesn't have a parent space and won't be included in the measure: #{s.name}")
        next
      end

      # calculate the absolute azimuth to determine orientation
      absolute_azimuth =  OpenStudio.convert(s.azimuth,"rad","deg").get + s.space.get.directionofRelativeNorth + model.getBuilding.northAxis
      until absolute_azimuth < 360.0
        absolute_azimuth = absolute_azimuth - 360.0
      end

      if not facade == "All"

        if facade == "North"
          next if not (absolute_azimuth >= 315.0 or absolute_azimuth < 45.0)
        elsif facade == "East"
          next if not (absolute_azimuth >= 45.0 and absolute_azimuth < 135.0)
        elsif facade == "South"
          next if not (absolute_azimuth >= 135.0 and absolute_azimuth < 225.0)
        elsif facade == "West"
          next if not (absolute_azimuth >= 225.0 and absolute_azimuth < 315.0)
        else
          runner.registerError("unexpected value of facade:" + facade)
          return false
        end

      end

      # calculate surface area adjusting for zone multiplier
      space = s.space
      if not space.empty?
        zone = space.get.thermalZone
      end
      if not zone.empty?
        zone_mult = zone.get.multiplier
        if zone_mult > 1
        end
      else
        zone_mult = 1 #space is not in a thermal zone
      end
      surface_gross_area = s.grossArea * zone_mult

      # loop through subsurfaces and add area including multiplier
      ext_window_area = 0
      s.subSurfaces.each do |subSurface| #only one and should have multiplier of 1
        ext_window_area = ext_window_area + subSurface.grossArea * subSurface.multiplier * zone_mult
      end

      final_gross_ext_wall_area += surface_gross_area
      final_ext_window_area += ext_window_area

    end

    # short def to make numbers pretty (converts 4125001.25641 to 4,125,001.26 or 4,125,001). The definition be called through this measure
    def neat_numbers(number, roundto = 2) #round to 0 or 2)

      # round to zero or two decimals
      if roundto == 2
        number = sprintf "%.2f", number
      else
        number = number.round
      end

      # regex to add commas
      number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse

    end

    # calculate change in window area
    increase_window_area_si = OpenStudio::Quantity.new(final_ext_window_area - starting_ext_window_area, unit_area_si)
    increase_window_area_ip = OpenStudio.convert(increase_window_area_si, unit_area_ip).get

    # calculate final envelope cost as positive value
    constructions = model.getConstructions
    constructions.each do |construction|
      const_lccs = construction.lifeCycleCosts
      const_lccs.each do |const_lcc|
        if const_lcc.category == "Construction"
          envelope_cost += const_lcc.totalCost
        end
      end
    end

    final_wwr = sprintf("%.02f",(final_ext_window_area/final_gross_ext_wall_area))
    runner.registerFinalCondition("window to wall ratio for #{facade} exterior walls = #{final_wwr}")

    if function == "Add" or function == "Replace"
      runner.registerInfo("number of windows added or replaced = #{add_replace_count}")
    elsif function == "Remove"
      runner.registerInfo("number of windows removed = #{remove_count}")
    end

    runner.registerInfo("window area change = #{neat_numbers(increase_window_area_ip.value,0)} ft2.")
    #runner.registerWarning("The material and construction costs increased by $#{neat_numbers(envelope_cost,0)}.")

    # warn user to surface match prior to running measure
    runner.registerWarning("Surface match before applying this measure to avoid adding windows to interior partition walls.")

    # warn user to remove window overhangs before removing windows
    runner.registerWarning("Remove window overhangs before removing windows.")

    return true

  end #run method

end #the measure

# this allows the measure to be used by the application
AddRemoveOrReplaceWindows.new.registerWithApplication
