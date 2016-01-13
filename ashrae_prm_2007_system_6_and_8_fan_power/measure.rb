# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/measures/measure_writing_guide/

require "#{File.dirname(__FILE__)}/resources/HVACSizing.AirTerminalSingleDuctParallelPIUReheat"
require "#{File.dirname(__FILE__)}/resources/HVACSizing.FanConstantVolume"
require "#{File.dirname(__FILE__)}/resources/HVACSizing.Model"

# start the measure
class ASHRAEPRM2007System6and8FanPower < OpenStudio::Ruleset::ModelUserScript

  # human readable name
  def name
    return "ASHRAE PRM 2007 System 6 and 8 Fan Power"
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
    sizing_run.setDescription("Set to TRUE if using Apply Measure Now.")
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
    # get model objects from classes
    pfp_boxes = model.getAirTerminalSingleDuctParallelPIUReheats

    # initialize variables
    pfp_boxes_count = 0
    pfp_fan_count = 0

    # DO STUFF

    # stdout messages
    puts ""
    puts "START PFP BOX FAN POWER MEASURE"

#    if sizing_run == true
      model.runSizingRun
#    end

    pfp_boxes.each do |pfp_box|

      runner.registerInfo("Setting fields for: #{pfp_box.name}")

'90.1-2007 ADDENDUM R:
G3.1.3.14 Fan Power (Systems 6 and 8). Fans in parallel
VAV fan-powered boxes shall be sized for 50% of the peak
design primary air (from the VAV air-handling unit) flow rate
and shall be modeled with 03.35 W/cfm (0.74 W per L/s) fan
power. Minimum volume setpoints for fan-powered boxes
shall be equal to 30% of peak design primary airflow rate or
the rate required to meet the minimum outdoor air ventilation
requirement, whichever is larger. The supply air temperature
setpoint shall be constant at the design condition.
'
      # set terminal air flow rates
#      if pfp_box.isMaximumPrimaryAirFlowRateAutosized

        maximum_primary_air_flow_rate = pfp_box.autosizedMaximumPrimaryAirFlowRate.get
        runner.registerInfo("=> Maximum Primary Air Flow Rate = #{maximum_primary_air_flow_rate} m3/s")
        pfp_box.setMinimumPrimaryAirFlowFraction(0.3) #TODO or OA requirement
        pfp_box.setMaximumSecondaryAirFlowRate(maximum_primary_air_flow_rate * 0.5) #TODO compare to fan flow rate
'
      else

        runner.registerWarning("Maximum Primary Air Flow Rate not autosized: #{pfp_box.name}")
        next

      end
'
      # set fan efficacy to 0.35 W/cfm
      fan = pfp_box.fan.to_FanConstantVolume.get

#      if fan.isMaximumFlowRateAutosized

        fan_flow_si = fan.autosizedMaximumFlowRate.get
        fan_flow_ip = OpenStudio.convert(fan_flow_si, "m^3/s", "ft^3/min").get
        runner.registerInfo("=> Maximum Fan Flow Rate = #{fan_flow_si} m3/s")
        runner.registerInfo("=> Maximum Secondary Air Flow Rate = #{pfp_box.maximumSecondaryAirFlowRate.get} m3/s")
'
      else

        runner.registerWarning("Maximum Flow Rate not autosized: #{pfp_box.name}")
        next

      end
'
      fan_rise_si = fan.pressureRise
      fan_rise_ip = OpenStudio.convert(fan_rise_si, "Pa", "inH_{2}O")
      runner.registerInfo("=> Pressure Rise = #{fan_rise_si} Pa")

      fan_efficiency = fan.fanEfficiency
      runner.registerInfo("=> Fan Total Efficiency = #{fan_efficiency}")

      fan_power = fan_rise_si * fan_flow_si / fan_efficiency
      fan_efficacy_calc = fan_power / fan_flow_si
      runner.registerInfo("=> fan efficacy calculated = #{fan_efficacy_calc} W-s/m3")

      #fan_efficacy_ip = 0.35 # W/cfm
      #fan_efficacy_si = 1 / OpenStudio.convert(1/fan_efficacy_ip, "ft^3/min", "m^3/s").get
      fan_efficacy_si = 0.74 * 1000

      fan_rise_si_new = fan_efficacy_si * fan_efficiency
      runner.registerInfo("=> fan pressure rise new = #{fan_rise_si_new} Pa")
      fan.setPressureRise(fan_rise_si_new)
      fan_power_new = fan_rise_si_new * fan_flow_si / fan_efficiency
      fan_efficacy_ip_new = fan_power_new / fan_flow_ip
      runner.registerInfo("=> new fan efficacy calculated = #{fan_efficacy_ip_new.round(2)} W/CFM")

      # reporting
      pfp_boxes_count += 1
      pfp_fan_count += 1

    end

    puts "END PFP BOX FAN POWER MEASURE"
    puts ""

    # report initial condition of model
    runner.registerInitialCondition("Number of PFP boxes in model = #{pfp_boxes_count}")

    # report final condition of model
    runner.registerFinalCondition("Number of PFP box fans changed = #{pfp_fan_count}")

    return true

  end

end

# register the measure to be used by the application
ASHRAEPRM2007System6and8FanPower.new.registerWithApplication
