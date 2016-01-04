# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class RemoveHVACSystems < OpenStudio::Ruleset::ModelUserScript

  # human readable name
  def name
    return "Remove HVAC Systems"
  end

  # human readable description
  def description
    return "TODO"
  end

  # human readable description of modeling approach
  def modeler_description
    return "TODO"
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new

#TODO bool exh_fans...
#TODO bool shw_loops...

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables

    # check the space_name for reasonableness

    # report initial condition of model
#    runner.registerInitialCondition("The building started with #{model.getSpaces.size} spaces.")

    # get model objects
    air_loops = model.getAirLoopHVACs
    wtr_loops = model.getPlantLoops
    zones = model.getThermalZones

    # initialize variables
    air_loops_count = 0
    wtr_loops_count = 0
    zone_eqpt_count = 0

    # DO STUFF

    # remove air loops
    runner.registerInfo("Removing Air Loops")

    air_loops.each do |al|

      runner.registerInfo("=> removing air loop: #{al.name}")
      al.remove
      air_loops_count += 1

    end

    # remove plant loops
    runner.registerInfo("Removing Plant Loops")

    wtr_loops.each do |wl|

      if wl.name.to_s.include? "SHW"

        runner.registerInfo("=> skipping plant loop: #{wl.name}") #TODO
        next

      else

        runner.registerInfo("=> removing plant loop: #{wl.name}")
        wl.remove
        wtr_loops_count += 1

      end

    end

    # remove zone equipment
    zones.each do |z|

      runner.registerInfo("Removing Zone Equipment from: #{z.name}")

      z.equipment.each do |ze|

        if ze.to_FanZoneExhaust.is_initialized #or (equip.to_ZoneHVACUnitHeater.is_initialized and zone.get.equipment.size == 1)

          next

        else

          runner.registerInfo("=> removing zone equipment: #{ze.name}") #no work
          ze.remove
          zone_eqpt_count += 1

        end

      end

    end

    # report final condition of model
#    runner.registerFinalCondition("The building finished with #{model.getSpaces.size} spaces.")

    return true

  end

end

# register the measure to be used by the application
RemoveHVACSystems.new.registerWithApplication
