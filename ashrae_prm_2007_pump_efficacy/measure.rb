# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require "#{File.dirname(__FILE__)}/resources/HVACSizing.PumpConstantSpeed"
require "#{File.dirname(__FILE__)}/resources/HVACSizing.PumpVariableSpeed"
require "#{File.dirname(__FILE__)}/resources/HVACSizing.Model"

# start the measure
class ASHRAEPRM2007PumpEfficacy < OpenStudio::Ruleset::ModelUserScript

  # human readable name
  def name
    return "ASHRAE PRM 2007 Pump Efficacy"
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
'
    sizing_run = OpenStudio::Ruleset::OSArgument::makeBoolArgument("sizing_run", false)
    sizing_run.setDisplayName("Run sizing run?")
    sizing_run.setDescription("Set to TRUE if using Apply Measure Now")
    sizing_run.setDefaultValue(false)
    args << sizing_run
'
    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end
'
    # get user arguments
    sizing_run = runner.getBoolArgumentValue("sizing_run", user_arguments)
'
    # get objects
    plant_loops = model.getPlantLoops

    # initialize variables
    hhw_pumps = 0
    chw_pumps = 0

    # DO STUFF

    # stdout messages
    puts ""
    puts "START PUMP EFFICACY"

#    if sizing_run == true
      model.runSizingRun
#    end

    plant_loops.each do |pl|

      supply_components = pl.supplyComponents

      loop_type = pl.sizingPlant.loopType

      supply_components.each do |sc|

        if sc.to_PumpConstantSpeed.is_initialized
          pump = sc.to_PumpConstantSpeed.get
        elsif sc.to_PumpVariableSpeed.is_initialized
          pump = sc.to_PumpVariableSpeed.get
        else
          next #not a pump
        end

#      if pump.isRatedFlowRateAutosized

          runner.registerInfo("Plant Loop: #{pl.name}")
          runner.registerInfo("=> setting power consumption for pump: #{pump.name}")

          pump_flow_si = pump.autosizedRatedFlowRate.to_f #OptionalDouble
          pump_flow_ip = OpenStudio.convert(pump_flow_si,"m^3/s","gal/min").get

#TODO puts to stdout
          puts "FLOW SI = #{pump_flow_si}"
          puts "FLOW IP = #{pump_flow_ip}"

          if loop_type == "Cooling"

            pump_power = pump_flow_ip * 22
            pump.setRatedPowerConsumption(pump_power)
            runner.registerInfo("=> rated power consumption = #{pump_power} W")

          elsif loop_type == "Condenser"

            pump_power = pump_flow_ip * 19
            pump.setRatedPowerConsumption(pump_power)
            runner.registerInfo("=> rated power consumption = #{pump_power} W")

          elsif loop_type == "Heating"

            pump_power = pump_flow_ip * 19
            pump.setRatedPowerConsumption(pump_power)
            runner.registerInfo("=> rated power consumption = #{pump_power} W")

          end

          runner.registerInfo("=> rated flow rate = #{pump_flow_ip}")
          efficacy = pump_power / pump_flow_ip
          runner.registerInfo("=> pump efficacy = #{efficacy.round(1)}")
'
        else

          runner.registerWarning("Pump flow rate not autosized: #{pump.name}")

        end
'
      end

    end

    puts "END PUMP EFFICACY"
    puts ""

    # report initial condition of model
    #runner.registerInitialCondition("The building started with #{model.getSpaces.size} spaces.")

    # echo the new space's name back to the user
    #runner.registerInfo("Space #{new_space.name} was added.")

    # report final condition of model
    #runner.registerFinalCondition("The building finished with #{model.getSpaces.size} spaces.")

    return true

  end

end

# register the measure to be used by the application
ASHRAEPRM2007PumpEfficacy.new.registerWithApplication
