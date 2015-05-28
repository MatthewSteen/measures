# start the measure
class SetFanInputs < OpenStudio::Ruleset::ModelUserScript

  # define the name that the user will see
  def name
    return "Set Fan Inputs"
  end

  # define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

		string = OpenStudio::Ruleset::OSArgument::makeStringArgument("string", false)
		string.setDisplayName("Set inputs for equipment containing the string:")
    string.setDescription("(case sensitive, leave blank for all)")
		args << string

    fan_choices = OpenStudio::StringVector.new
    fan_choices << "FanConstantVolume"
    fan_choices << "FanOnOff"
    fan_choices << "FanVariableVolume"
    fan_choices << "FanZoneExhaust"
    fan_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("fan_type", fan_choices, true)
    fan_type.setDisplayName("Fan Type")
    fan_type.setDefaultValue("FanConstantVolume")
    args << fan_type

    #populate choice argument for schedules in the model
    sch_handles = OpenStudio::StringVector.new
    sch_display_names = OpenStudio::StringVector.new
    #putting schedule names into hash
    sch_hash = {}
    model.getSchedules.each do |sch|
      sch_hash[sch.name.to_s] = sch
    end
    #looping through sorted hash of schedules
    sch_hash.sort.map do |sch_name, sch|
      if not sch.scheduleTypeLimits.empty?
        unitType = sch.scheduleTypeLimits.get.unitType
        #puts "#{sch.name}, #{unitType}"
        if unitType == "Availability"
          sch_handles << sch.handle.to_s
          sch_display_names << sch_name
        end
      end
    end

    # common arguments
    fan_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("fan_sched", sch_handles, sch_display_names, false)
    fan_sched.setDisplayName("Availability Schedule Name")
    args << fan_sched

    fan_eff_tot = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_eff_tot", false)
    fan_eff_tot.setDisplayName("Fan Total Efficiency")
    args << fan_eff_tot

    fan_rise = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_rise", false)
    fan_rise.setDisplayName("Pressure Rise {inH2O}")
    args << fan_rise

    fan_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_flow", false)
    fan_flow.setDisplayName("Maximum Flow Rate {ft3/min}")
    args << fan_flow

    fan_eff_mot = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_eff_mot", false)
    fan_eff_mot.setDisplayName("Motor Efficiency")
    args << fan_eff_mot

    fan_mot_heat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_mot_heat", false)
    fan_mot_heat.setDisplayName("Motor In Airstream Fraction")
    args << fan_mot_heat

    #TODO not exposed in GUI as of 1.7.4
'    fan_end_use = OpenStudio::Ruleset::OSArgument::makeStringArgument("fan_end_use", false)
    fan_end_use.setDisplayName("End-Use Subcategory")
    args << fan_end_use
'
    # FanOnOff
    # TODO curves?

    # FanVariableVolume
    vav_choices = OpenStudio::StringVector.new
    vav_choices << "FixedFlowRate"
    vav_choices << "Fraction"
    vav_min_flow_method = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("vav_min_flow_method", vav_choices, true)
    vav_min_flow_method.setDisplayName("VAV: Fan Power Minimum Flow Rate Input Method")
    vav_min_flow_method.setDefaultValue("Fraction")
    args << vav_min_flow_method

    vav_min_flow_frac = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_min_flow_frac", false)
    vav_min_flow_frac.setDisplayName("VAV: Fan Power Minimum Flow Fraction")
    args << vav_min_flow_frac

    vav_min_flow_rate = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_min_flow_rate", false)
    vav_min_flow_rate.setDisplayName("VAV: Fan Power Minimum Air Flow Rate {ft3/min}")
    args << vav_min_flow_rate

    vav_c1 = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_c1", false)
    vav_c1.setDisplayName("VAV: Fan Power Coefficient 1")
    args << vav_c1

    vav_c2 = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_c2", false)
    vav_c2.setDisplayName("VAV: Fan Power Coefficient 2")
    args << vav_c2

    vav_c3 = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_c3", false)
    vav_c3.setDisplayName("VAV: Fan Power Coefficient 3")
    args << vav_c3

    vav_c4 = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_c4", false)
    vav_c4.setDisplayName("VAV: Fan Power Coefficient 4")
    args << vav_c4

    vav_c5 = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_c5", false)
    vav_c5.setDisplayName("VAV: Fan Power Coefficient 5")
    args << vav_c5

    # FanZoneExhaust
    ef_end_use = OpenStudio::Ruleset::OSArgument::makeStringArgument("ef_end_use", false)
    ef_end_use.setDisplayName("EF: End-Use Subcategory")
    args << ef_end_use

    ef_flow_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ef_flow_sched", sch_handles, sch_display_names, false)
    ef_flow_sched.setDisplayName("EF: Flow Fraction Schedule Name")
    args << ef_flow_sched

    ef_choices = OpenStudio::StringVector.new
    ef_choices << "Coupled"
    ef_choices << "Decoupled"
    ef_mode = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ef_mode", ef_choices, true)
    ef_mode.setDisplayName("EF: System Availability Manager Coupling Mode")
    ef_mode.setDefaultValue("Coupled")
    args << ef_mode

    ef_temp_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ef_temp_sched", sch_handles, sch_display_names, false)
    ef_temp_sched.setDisplayName("EF: Minimum Zone Temperature Limit Schedule Name TODO") #TODO not working
    args << ef_temp_sched

    ef_balance_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ef_balance_sched", sch_handles, sch_display_names, false)
    ef_balance_sched.setDisplayName("EF: Balanced Exhaust Fraction Schedule Name")
    args << ef_balance_sched

    return args

  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    super(model, runner, user_arguments)

    # use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # get user arguments if not empty, convert to SI units for simulation
    string = runner.getOptionalStringArgumentValue("string", user_arguments)
    string = string.to_s #implicit conversion for optional string
    fan_type = runner.getStringArgumentValue("fan_type", user_arguments)

    fan_sched = runner.getOptionalWorkspaceObjectChoiceValue("fan_sched", user_arguments, model)
    if fan_sched.empty?
      fan_sched = nil
    else
      fan_sched = fan_sched.get.to_Schedule.get
    end

    fan_eff_tot = runner.getOptionalDoubleArgumentValue("fan_eff_tot", user_arguments)
    if fan_eff_tot.empty?
      fan_eff_tot = nil
    else
      fan_eff_tot = fan_eff_tot.get
    end

    fan_rise = runner.getOptionalDoubleArgumentValue("fan_rise", user_arguments)
    if fan_rise.empty?
      fan_rise = nil
    else
      fan_rise = fan_rise.get
      fan_rise_si = OpenStudio.convert(fan_rise, "inH_{2}O", "Pa").get
    end

    fan_flow = runner.getOptionalDoubleArgumentValue("fan_flow", user_arguments)
    if fan_flow.empty?
      fan_flow = nil
    else
      fan_flow = fan_flow.get
      fan_flow_si = OpenStudio.convert(fan_flow, "ft^3/min", "m^3/s").get
    end

    fan_eff_mot = runner.getOptionalDoubleArgumentValue("fan_eff_mot", user_arguments)
    if fan_eff_mot.empty?
      fan_eff_mot = nil
    else
      fan_eff_mot = fan_eff_mot.get
    end

    fan_mot_heat = runner.getOptionalDoubleArgumentValue("fan_mot_heat", user_arguments)
    if fan_mot_heat.empty?
      fan_mot_heat = nil
    else
      fan_mot_heat = fan_mot_heat.get
    end
'
    fan_end_use = runner.getOptionalStringArgumentValue("fan_end_use", user_arguments)
    fan_end_use = fan_end_use.to_s #implicit conversion for optional string
'
    if fan_type == "FanVariableVolume"

      vav_min_flow_method = runner.getStringArgumentValue("vav_min_flow_method", user_arguments)

      vav_min_flow_frac = runner.getOptionalDoubleArgumentValue("vav_min_flow_frac", user_arguments)
      if vav_min_flow_frac.empty?
        vav_min_flow_frac = nil
      else
        vav_min_flow_frac = vav_min_flow_frac.get
      end

      vav_min_flow_rate = runner.getOptionalDoubleArgumentValue("vav_min_flow_rate", user_arguments)
      if vav_min_flow_rate.empty?
        vav_min_flow_rate = nil
      else
        vav_min_flow_rate = vav_min_flow_rate.get
        vav_min_flow_rate_si = OpenStudio.convert(vav_min_flow_rate, "ft^3/min", "m^3/s").get
      end

      vav_c1 = runner.getOptionalDoubleArgumentValue("vav_c1", user_arguments)
      if vav_c1.empty?
        vav_c1 = nil
      else
        vav_c1 = vav_c1.get
      end

      vav_c2 = runner.getOptionalDoubleArgumentValue("vav_c2", user_arguments)
      if vav_c2.empty?
        vav_c2 = nil
      else
        vav_c2 = vav_c2.get
      end

      vav_c3 = runner.getOptionalDoubleArgumentValue("vav_c3", user_arguments)
      if vav_c3.empty?
        vav_c3 = nil
      else
        vav_c3 = vav_c3.get
      end

      vav_c4 = runner.getOptionalDoubleArgumentValue("vav_c4", user_arguments)
      if vav_c4.empty?
        vav_c4 = nil
      else
        vav_c4 = vav_c4.get
      end

      vav_c5 = runner.getOptionalDoubleArgumentValue("vav_c5", user_arguments)
      if vav_c5.empty?
        vav_c5 = nil
      else
        vav_c5 = vav_c5.get
      end

    end

    if fan_type == "FanZoneExhaust"

      ef_end_use = runner.getOptionalStringArgumentValue("ef_end_use", user_arguments)
      if ef_end_use.empty?
        ef_end_use = nil
      else
        ef_end_use = ef_end_use.get
      end

      ef_flow_sched = runner.getOptionalWorkspaceObjectChoiceValue("ef_flow_sched", user_arguments, model)
      if ef_flow_sched.empty?
        ef_flow_sched = nil
      else
        ef_flow_sched = ef_flow_sched.get.to_Schedule.get
      end

      ef_mode = runner.getOptionalStringArgumentValue("ef_mode", user_arguments)
      if ef_mode.empty?
        ef_mode = nil
      else
        ef_mode = ef_mode.get
      end

      ef_temp_sched = runner.getOptionalWorkspaceObjectChoiceValue("ef_temp_sched", user_arguments, model)
      if ef_temp_sched.empty?
        ef_temp_sched = nil
      else
        ef_temp_sched = ef_temp_sched.get.to_Schedule.get
      end

      ef_balance_sched = runner.getOptionalWorkspaceObjectChoiceValue("ef_balance_sched", user_arguments, model)
      if ef_balance_sched.empty?
        ef_balance_sched = nil
      else
        ef_balance_sched = ef_balance_sched.get.to_Schedule.get
      end

    end

    # get model objects, report initial conditions
    if fan_type == "FanConstantVolume"
      fans = model.getFanConstantVolumes
      runner.registerInitialCondition("Number of CAV fans in model = #{fans.size}")
    elsif fan_type == "FanOnOff"
      fans = model.getFanOnOffs
      runner.registerInitialCondition("Number of OnOff fans in model = #{fans.size}")
    elsif fan_type == "FanVariableVolume"
      fans = model.getFanVariableVolumes
      runner.registerInitialCondition("Number of VAV fans in model = #{fans.size}")
    elsif fan_type == "FanZoneExhaust"
      fans = model.getFanZoneExhausts
      runner.registerInitialCondition("Number of exhaust fans in model = #{fans.size}")
    else
      runner.registerError("Fan type not found")
    end

    # initialize variables
    counter = 0

    # set fan inputs
    fans.each do |fan|

      if string.empty? or fan.name.to_s.include? string

        # common inputs
        fan.setAvailabilitySchedule(fan_sched) unless fan_sched.nil?
        fan.setFanEfficiency(fan_eff_tot) unless fan_eff_tot.nil?
        fan.setPressureRise(fan_rise_si) unless fan_rise.nil?
        fan.setMaximumFlowRate(fan_flow_si) unless fan_flow.nil?
        if fan_type != "FanZoneExhaust"
          fan.setMotorEfficiency(fan_eff_mot) unless fan_eff_mot.nil?
          fan.setMotorInAirstreamFraction(fan_mot_heat) unless fan_mot_heat.nil?
        end
'
        if not fan_end_use.empty?
          fan.setEndUseSubcategory(fan_end_use)
        end
'
        # on off inputs
        if fan_type == "FanOnOff"
          #TODO future curves
        end

        # vav inputs
        if fan_type == "FanVariableVolume"
          fan.setFanPowerMinimumFlowRateInputMethod(vav_min_flow_method)
          fan.setFanPowerMinimumFlowFraction(vav_min_flow_frac) unless vav_min_flow_frac.nil?
          fan.setFanPowerMinimumAirFlowRate(vav_min_flow_rate_si) unless vav_min_flow_rate.nil?
          fan.setFanPowerCoefficient1(vav_c1) unless vav_c1.nil?
          fan.setFanPowerCoefficient2(vav_c2) unless vav_c2.nil?
          fan.setFanPowerCoefficient3(vav_c3) unless vav_c3.nil?
          fan.setFanPowerCoefficient4(vav_c4) unless vav_c4.nil?
        	fan.setFanPowerCoefficient5(vav_c5) unless vav_c5.nil?
        end

        # exhaust fan inputs
        if fan_type == "FanZoneExhaust"

          fan.setEndUseSubcategory(ef_end_use) unless ef_end_use.nil?
          fan.setFlowFractionSchedule(ef_flow_sched) unless ef_flow_sched.nil?
          fan.setSystemAvailabilityManagerCouplingMode(ef_mode) unless ef_mode.nil?
          fan.setMinimumZoneTemperatureLimitSchedule(ef_temp_sched) unless ef_temp_sched.nil?
          fan.setBalancedExhaustFractionSchedule(ef_balance_sched) unless ef_balance_sched.nil?

        end

        counter += 1

      end

    end #main

    # report final conditions
    runner.registerFinalCondition("Number of fans changed = #{counter}")

    return true

  end #def

end #class

#this allows the measure to be used by the application
SetFanInputs.new.registerWithApplication
