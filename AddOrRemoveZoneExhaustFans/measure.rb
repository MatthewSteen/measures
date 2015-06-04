# start the measure
class AddZoneExhaustBySpaceType < OpenStudio::Ruleset::ModelUserScript

  #define the name that a user will see, this method may be deprecated as
  #the display name in PAT comes from the name field in measure.xml
  def name
    return "Add Or Remove Zone Exhaust Fans"
  end

  #define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new

    function_choices = OpenStudio::StringVector.new
    function_choices << "Add"
    function_choices << "Remove"
    function = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('function', function_choices, true)
    function.setDisplayName("Select measure function:")
    args << function

    apply_choices = OpenStudio::StringVector.new
    apply_choices << "By Name"
    apply_choices << "By Space Type"
    apply = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('apply', apply_choices, true)
    apply.setDisplayName("Select how measure is applied:")
    args << apply

    string = OpenStudio::Ruleset::OSArgument::makeStringArgument("string", false)
    string.setDisplayName("Add Exhaust Fan to Zones Containing the String")
    string.setDescription("(case sensitive, leave blank for all)")
		args << string

    #argument for space types
    space_type_handles = OpenStudio::StringVector.new
    space_type_display_names = OpenStudio::StringVector.new

    #putting model object and names into hash
    space_type_args = model.getSpaceTypes
    space_type_args_hash = {}
    space_type_args.each do |space_type_arg|
      space_type_args_hash[space_type_arg.name.to_s] = space_type_arg
    end

    #looping through sorted hash of model objects
    space_type_args_hash.sort.map do |key,value|
      #only include if space type is used in the model
      if value.spaces.size > 0
        space_type_handles << value.handle.to_s
        space_type_display_names << key
      end
    end

    #add building to string vector with space type
    building = model.getBuilding
    space_type_handles << building.handle.to_s
    space_type_display_names << "*All Space Types*"

    #make a choice argument for space type or entire building
    space_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("space_type", space_type_handles, space_type_display_names,false)
    space_type.setDisplayName("Space Type (NOT ENABLED)")
    space_type.setDefaultValue("*Entire Building*") #if no space type is chosen this will run on the entire building
    args << space_type
'
    name = OpenStudio::Ruleset::OSArgument::makeStringArgument("name", false)
    name.setDisplayName("Attach name to exhaust fan (optional) REMOVE")
    name.setDefaultValue("EF") #TODO
    args << name
'
    return args

  end #end the arguments method

  #define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    #use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    #assign the user inputs to variables
    function = runner.getStringArgumentValue("function", user_arguments)
    apply = runner.getStringArgumentValue("apply", user_arguments)
    string = runner.getOptionalStringArgumentValue("string", user_arguments)
    string = string.to_s #implicit conversion for optional string
    name = runner.getOptionalStringArgumentValue("name", user_arguments)
    name = name.to_s
    space_types = runner.getOptionalWorkspaceObjectChoiceValue("space_type", user_arguments, model) #model is passed in because of argument type

		# get model objects
    zones = model.getThermalZones
    fans = model.getFanZoneExhausts

    # report initial condition
    runner.registerInitialCondition("number of exhaust fans in the model = #{fans.size}")

    # initialize variables
    count_fans = 0

    # functions
    def add_fan(model, zone)
      new_fan = OpenStudio::Model::FanZoneExhaust.new(model)
      new_fan.setName("#{zone.name} EF") #TODO
      new_fan.addToThermalZone(zone)
    end

    def rem_fan(model, zone)

      zone_eqpt = zone.equipment

      zone_eqpt.each do |eqpt|

        if eqpt.to_FanZoneExhaust.is_initialized
          fan = eqpt.to_FanZoneExhaust.get
          fan.remove
        end

      end

    end

    # add or remove exhaust fans
    zones.each do |zone|
'
      if apply == "By Space Type"

        spaces = zone.spaces


      elsif apply == "By Name"
'
      if string.empty? or zone.name.to_s.include? string

        if function == "Remove"

          rem_fan(model, zone)
          count_fans += 1
'
          zone_eqpt = zone.equipment

          zone_eqpt.each do |eqpt|

            if eqpt.to_FanZoneExhaust.is_initialized
              fan = eqpt.to_FanZoneExhaust.get
              fan.remove
              count_fans += 1
            end

          end
'
        elsif function == "Add"

          add_fan(model, zone)
          count_fans += 1
'
          new_fan = OpenStudio::Model::FanZoneExhaust.new(model)
          new_fan.setName("#{zone.name} EF") #TODO
          new_fan.addToThermalZone(zone)
          count_fans += 1
'
        end

      end

    end

    # report final condition
    if function == "Add"
      runner.registerFinalCondition("number of exhaust fans added = #{count_fans}")
    elsif function == "Remove"
      runner.registerFinalCondition("number of exhaust fans removed = #{count_fans}")
    end
'
          new_fan.setAvailabilitySchedule(sched)
          new_fan.setFanEfficiency(efficiency)
          new_fan.setPressureRise(pressure)
          new_fan.setMaximumFlowRate(flow)
          new_fan.setSystemAvailabilityManagerCouplingMode(mode)
          new_fan.addToThermalZone(z)
        end
      end

      runner.registerInfo("Added #{fans.size} Exhaust Fans")

    else
      nil #runner.registerError("error")
    end
'
'#TODO - for zones only, use ZoneHVACEquipmentList?
   zones.each do |z|
        spaces = z.spaces
        spaces.each do |s|
          if s.spaceType == space_type
         spaces.each do |s|
        if s.spaceType == space_type
          s.thermalZone.

    runner.registerInfo("Adding exhaust fans")
		model.getThermalZones.each do |zone|
			if zone.name.to_s.include? string
				runner.registerInfo("Adding exhaust fan to #{zone.name}")
				new_fan = OpenStudio::Model::FanZoneExhaust.new(model)
				new_fan.setName("#{zone.name} Exhaust Fan")
				new_fan.setAvailabilitySchedule(sched)
				new_fan.setFanEfficiency(efficiency)
				new_fan.setPressureRise(pressure)
				new_fan.setMaximumFlowRate(flow)
				new_fan.setSystemAvailabilityManagerCouplingMode(mode)
				new_fan.addToThermalZone(zone)
			else
				nil
			end
		end
'
    return true

  end #run method

end #measure

#this allows the measure to be use by the application
AddZoneExhaustBySpaceType.new.registerWithApplication
