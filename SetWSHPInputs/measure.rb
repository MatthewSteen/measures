# start the measure
class SetWSHPInputs < OpenStudio::Ruleset::ModelUserScript

  #define the name that a user will see, this method may be deprecated as
  #the display name in PAT comes from the name field in measure.xml
  def name
    return "Set WSHP Inputs"
  end

  # define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    string = OpenStudio::Ruleset::OSArgument::makeStringArgument("string", false)
		string.setDisplayName("Set inputs for equipment containing the string:")
    string.setDescription("(case sensitive, leave blank for all)")
		args << string

    autosize = OpenStudio::Ruleset::OSArgument::makeBoolArgument("autosize", false)
    autosize.setDisplayName("TODO Autosize all fields?")
    autosize.setDefaultValue(false)
    args << autosize

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
'v8.3
ZoneHVAC:WaterToAirHeatPump,
    x,                        !- Name
    ,                        !- Availability Schedule Name
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    ,                        !- Outdoor Air Mixer Object Type
    ,                        !- Outdoor Air Mixer Name
    x,                        !- Cooling Supply Air Flow Rate {m3/s}
    x,                        !- Heating Supply Air Flow Rate {m3/s}
    x,                        !- No Load Supply Air Flow Rate {m3/s}
    x,                        !- Cooling Outdoor Air Flow Rate {m3/s}
    x,                        !- Heating Outdoor Air Flow Rate {m3/s}
    x,                        !- No Load Outdoor Air Flow Rate {m3/s}
    ,                        !- Supply Air Fan Object Type
    ,                        !- Supply Air Fan Name
    ,                        !- Heating Coil Object Type
    ,                        !- Heating Coil Name
    ,                        !- Cooling Coil Object Type
    ,                        !- Cooling Coil Name
    2.5,                     !- Maximum Cycling Rate {cycles/hr}
    60,                      !- Heat Pump Time Constant {s}
    0.01,                    !- Fraction of On-Cycle Power Use
    60,                      !- Heat Pump Fan Delay Time {s}
    ,                        !- Supplemental Heating Coil Object Type
    ,                        !- Supplemental Heating Coil Name
    ,                        !- Maximum Supply Air Temperature from Supplemental Heater {C}
    21,                      !- Maximum Outdoor Dry-Bulb Temperature for Supplemental Heater Operation {C}
    ,                        !- Outdoor Dry-Bulb Temperature Sensor Node Name
    BlowThrough,             !- Fan Placement
    ,                        !- Supply Air Fan Operating Mode Schedule Name
    ,                        !- Availability Manager List Name
    Cycling,                 !- Heat Pump Coil Water Flow Mode
    0;                       !- Design Specification ZoneHVAC Sizing Object Name
'
    # wshp arguments
    wshp_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("wshp_sched", sch_handles, sch_display_names, false)
    wshp_sched.setDisplayName("WSHP: Availability Schedule Name")
    args << wshp_sched

    wshp_sa_clg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_sa_clg', false)
    wshp_sa_clg.setDisplayName("WSHP: Cooling Supply Air Flow Rate {ft3/min}")
    args << wshp_sa_clg

    wshp_sa_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_sa_htg', false)
    wshp_sa_htg.setDisplayName("WSHP: Heating Supply Air Flow Rate {ft3/min}")
    args << wshp_sa_htg

    wshp_sa_no_load = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_sa_no_load', false)
    wshp_sa_no_load.setDisplayName("WSHP: No Load Supply Air Flow Rate {ft3/min}")
    args << wshp_sa_no_load

    wshp_oa_clg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_oa_clg', false)
    wshp_oa_clg.setDisplayName("WSHP: Cooling Outdoor Air Flow Rate {ft3/min}")
    args << wshp_oa_clg

    wshp_oa_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_oa_htg', false)
    wshp_oa_htg.setDisplayName("WSHP: Heating Outdoor Air Flow Rate {ft3/min}")
    args << wshp_oa_htg

    wshp_oa_no_load = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_oa_no_load', false)
    wshp_oa_no_load.setDisplayName("WSHP: No Load Outdoor Air Flow Rate {ft3/min}")
    args << wshp_oa_no_load

    #TODO add args

    wshp_fan_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("wshp_fan_sched", sch_handles, sch_display_names, false)
    wshp_fan_sched.setDisplayName("WSHP: Supply Air Fan Operating Mode Schedule Name")
    args << wshp_fan_sched
'
Coil:Heating:WaterToAirHeatPump:EquationFit,
    ,                        !- Name
    ,                        !- Water Inlet Node Name
    ,                        !- Water Outlet Node Name
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    x,                        !- Rated Air Flow Rate {m3/s}
    x,                        !- Rated Water Flow Rate {m3/s}
    x,                        !- Gross Rated Heating Capacity {W}
    x,                        !- Gross Rated Heating COP
    ,                        !- Heating Capacity Coefficient 1
    ,                        !- Heating Capacity Coefficient 2
    ,                        !- Heating Capacity Coefficient 3
    ,                        !- Heating Capacity Coefficient 4
    ,                        !- Heating Capacity Coefficient 5
    ,                        !- Heating Power Consumption Coefficient 1
    ,                        !- Heating Power Consumption Coefficient 2
    ,                        !- Heating Power Consumption Coefficient 3
    ,                        !- Heating Power Consumption Coefficient 4
    1;                       !- Heating Power Consumption Coefficient 5
'
    # htg coil arguments
    hc_air_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_air_flow", false)
    hc_air_flow.setDisplayName("Htg Coil: Rated Air Flow Rate {ft3/min}")
    args << hc_air_flow

    hc_wtr_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_wtr_flow", false)
    hc_wtr_flow.setDisplayName("Htg Coil: Rated Water Flow Rate {ft3/min}")
    args << hc_wtr_flow

    hc_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_cap", false)
    hc_cap.setDisplayName("Htg Coil: Gross Rated Heating Capacity {Btu/h}")
    args << hc_cap

    hc_cop = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_cop", false)
    hc_cop.setDisplayName("Htg Coil: Gross Rated Heating COP")
    args << hc_cop
'
Coil:Cooling:WaterToAirHeatPump:EquationFit,
    ,                        !- Name
    ,                        !- Water Inlet Node Name
    ,                        !- Water Outlet Node Name
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    x,                        !- Rated Air Flow Rate {m3/s}
    x,                        !- Rated Water Flow Rate {m3/s}
    x,                        !- Gross Rated Total Cooling Capacity {W}
    x,                        !- Gross Rated Sensible Cooling Capacity {W}
    x,                        !- Gross Rated Cooling COP
    ,                        !- Total Cooling Capacity Coefficient 1
    ,                        !- Total Cooling Capacity Coefficient 2
    ,                        !- Total Cooling Capacity Coefficient 3
    ,                        !- Total Cooling Capacity Coefficient 4
    ,                        !- Total Cooling Capacity Coefficient 5
    ,                        !- Sensible Cooling Capacity Coefficient 1
    ,                        !- Sensible Cooling Capacity Coefficient 2
    ,                        !- Sensible Cooling Capacity Coefficient 3
    ,                        !- Sensible Cooling Capacity Coefficient 4
    ,                        !- Sensible Cooling Capacity Coefficient 5
    ,                        !- Sensible Cooling Capacity Coefficient 6
    ,                        !- Cooling Power Consumption Coefficient 1
    ,                        !- Cooling Power Consumption Coefficient 2
    ,                        !- Cooling Power Consumption Coefficient 3
    ,                        !- Cooling Power Consumption Coefficient 4
    ,                        !- Cooling Power Consumption Coefficient 5
    0.0,                     !- Nominal Time for Condensate Removal to Begin {s}
    0.0;                     !- Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity {dimensionless}
'
    # clg coil arguments
    cc_air_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_air_flow", false)
    cc_air_flow.setDisplayName("Clg Coil: Rated Air Flow Rate {ft3/min}")
    args << cc_air_flow

    cc_wtr_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_wtr_flow", false)
    cc_wtr_flow.setDisplayName("Clg Coil: Rated Water Flow Rate {ft3/min}")
    args << cc_wtr_flow

    cc_tot_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_tot_cap", false)
    cc_tot_cap.setDisplayName("Clg Coil: Gross Rated Cooling Capacity {Btu/h}")
    args << cc_tot_cap

    cc_sen_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_sen_cap", false)
    cc_sen_cap.setDisplayName("Clg Coil: Gross Rated Sensible Cooling Capacity {Btu/h}")
    args << cc_sen_cap

    cc_cop = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_cop", false)
    cc_cop.setDisplayName("Clg Coil: Gross Rated Cooling COP")
    args << cc_cop

    # supplemental HC arguments
    sc_choices = OpenStudio::StringVector.new
    sc_choices << "CoilHeatingElectric"
    sc_choices << "CoilHeatingGas"
    sc_choices << "CoilHeatingWater"
    sc_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("sc_type", sc_choices, false)
    sc_type.setDisplayName("Supplemental Heating Coil Object Type")
    args << sc_type

    sc_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("sc_cap", false)
    sc_cap.setDisplayName("Supplemental Coil Capacity (Btu/h)")
    args << sc_cap

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

    wshp_sched = runner.getOptionalWorkspaceObjectChoiceValue("wshp_sched", user_arguments, model)
    if wshp_sched.empty?
      wshp_sched = nil
    else
      wshp_sched = wshp_sched.get.to_Schedule.get
    end

    wshp_sa_clg = runner.getOptionalDoubleArgumentValue("wshp_sa_clg", user_arguments)
    if wshp_sa_clg.empty?
      wshp_sa_clg = nil
    else
      wshp_sa_clg = wshp_sa_clg.get
      wshp_sa_clg_si = OpenStudio.convert(wshp_sa_clg, "ft^3/min", "m^3/s").get
    end

    wshp_sa_htg = runner.getOptionalDoubleArgumentValue("wshp_sa_htg", user_arguments)
    if wshp_sa_htg.empty?
      wshp_sa_htg = nil
    else
      wshp_sa_htg = wshp_sa_htg.get
      wshp_sa_htg_si = OpenStudio.convert(wshp_sa_htg, "ft^3/min", "m^3/s").get
    end

    wshp_sa_no_load = runner.getOptionalDoubleArgumentValue("wshp_sa_no_load", user_arguments)
    if wshp_sa_no_load.empty?
      wshp_sa_no_load = nil
    else
      wshp_sa_no_load = wshp_sa_no_load.get
      wshp_sa_no_load_si = OpenStudio.convert(wshp_sa_no_load, "ft^3/min", "m^3/s").get
    end

    wshp_oa_clg = runner.getOptionalDoubleArgumentValue("wshp_oa_clg", user_arguments)
    if wshp_oa_clg.empty?
      wshp_oa_clg = nil
    else
      wshp_oa_clg = wshp_oa_clg.get
      wshp_oa_clg_si = OpenStudio.convert(wshp_oa_clg, "ft^3/min", "m^3/s").get
    end

    wshp_oa_htg = runner.getOptionalDoubleArgumentValue("wshp_oa_htg", user_arguments)
    if wshp_oa_htg.empty?
      wshp_oa_htg = nil
    else
      wshp_oa_htg = wshp_oa_htg.get
      wshp_oa_htg_si = OpenStudio.convert(wshp_oa_htg, "ft^3/min", "m^3/s").get
    end

    wshp_oa_no_load = runner.getOptionalDoubleArgumentValue("wshp_oa_no_load", user_arguments)
    if wshp_oa_no_load.empty?
      wshp_oa_no_load = nil
    else
      wshp_oa_no_load = wshp_oa_no_load.get
      wshp_oa_no_load_si = OpenStudio.convert(wshp_oa_no_load, "ft^3/min", "m^3/s").get
    end

    wshp_fan_sched = runner.getOptionalWorkspaceObjectChoiceValue("wshp_fan_sched", user_arguments, model)
    if wshp_fan_sched.empty?
      wshp_fan_sched = nil
    else
      wshp_fan_sched = wshp_fan_sched.get.to_Schedule.get
    end

    # htg coil
    hc_air_flow = runner.getOptionalDoubleArgumentValue("hc_air_flow", user_arguments)
    if hc_air_flow.empty?
      hc_air_flow = nil
    else
      hc_air_flow = hc_air_flow.get
      hc_air_flow_si = OpenStudio.convert(hc_air_flow, "ft^3/min", "m^3/s").get
    end

    hc_wtr_flow = runner.getOptionalDoubleArgumentValue("hc_wtr_flow", user_arguments)
    if hc_wtr_flow.empty?
      hc_wtr_flow = nil
    else
      hc_wtr_flow = hc_wtr_flow.get
      hc_wtr_flow_si = OpenStudio.convert(hc_wtr_flow, "gal/min", "m^3/s").get
    end

    hc_cap = runner.getOptionalDoubleArgumentValue("hc_cap", user_arguments)
    if hc_cap.empty?
      hc_cap = nil
    else
      hc_cap = hc_cap.get
      hc_cap_si = OpenStudio.convert(hc_cap, "Btu/h", "W").get
    end

    hc_cop = runner.getOptionalDoubleArgumentValue("hc_cop", user_arguments)
    if hc_cop.empty?
      hc_cop = nil
    else
      hc_cop = hc_cop.get
    end

    # clg coil
    cc_air_flow = runner.getOptionalDoubleArgumentValue("cc_air_flow", user_arguments)
    if cc_air_flow.empty?
      cc_air_flow = nil
    else
      cc_air_flow = cc_air_flow.get
      cc_air_flow_si = OpenStudio.convert(cc_air_flow, "ft^3/min", "m^3/s").get
    end

    cc_wtr_flow = runner.getOptionalDoubleArgumentValue("cc_wtr_flow", user_arguments)
    if cc_wtr_flow.empty?
      cc_wtr_flow = nil
    else
      cc_wtr_flow = cc_wtr_flow.get
      cc_wtr_flow_si = OpenStudio.convert(cc_wtr_flow, "gal/min", "m^3/s").get
    end

    cc_cap = runner.getOptionalDoubleArgumentValue("cc_cap", user_arguments)
    if cc_cap.empty?
      cc_cap = nil
    else
      cc_cap = cc_cap.get
      cc_cap_si = OpenStudio.convert(cc_cap, "Btu/h", "W").get
    end

    cc_sen_cap = runner.getOptionalDoubleArgumentValue("cc_sen_cap", user_arguments)
    if cc_sen_cap.empty?
      cc_sen_cap = nil
    else
      cc_sen_cap = cc_sen_cap.get
      cc_sen_cap_si = OpenStudio.convert(cc_sen_cap, "Btu/h", "W").get
    end

    cc_cop = runner.getOptionalDoubleArgumentValue("cc_cop", user_arguments)
    if cc_cop.empty?
      cc_cop = nil
    else
      cc_cop = cc_cop.get
    end

    # supplemental heating coil
    sc_type = runner.getOptionalWorkspaceObjectChoiceValue("sc_type", user_arguments, model)
    if sc_type.empty?
      sc_type = nil
    else
      sc_type = sc_type.get
    end

    sc_cap = runner.getOptionalDoubleArgumentValue("sc_cap", user_arguments)
    if sc_cap.empty?
      sc_cap = nil
    else
      sc_cap = sc_cap.get
      sc_cap_si = OpenStudio.convert(sc_cap, "Btu/h", "W").get
    end

    # get model objects
    wshps = model.getZoneHVACWaterToAirHeatPumps

    # report initial conditions
    runner.registerInitialCondition("Number of WSHPs in the model = #{wshps.size}")
    runner.registerInfo("String = #{string}")

    # initialize reporting variables
    count_wshps = 0
    error = false

    wshps.each do |wshp|

      if wshp.name.to_s.include? string or string == "*.*" # || doesn't work for 'or'

        runner.registerInfo("Setting fields for: #{wshp.name}")

        # get WSHP components
        hc = wshp.heatingCoil.to_CoilHeatingWaterToAirHeatPumpEquationFit.get
        cc = wshp.coolingCoil.to_CoilCoolingWaterToAirHeatPumpEquationFit.get
        if sc_type == "CoilHeatingElectric"
          sc = wshp.supplementalHeatingCoil.to_CoilHeatingElectric.get
        elsif sc_type == "to_CoilHeatingGas"
          sc = wshp.supplementalHeatingCoil.to_CoilHeatingGas.get
        elsif sc_type =="to_CoilHeatingWater"
          sc = wshp.supplementalHeatingCoil.to_CoilHeatingWater.get
        end

        # set WSHP fields
        wshp.setAvailabilitySchedule(wshp_sched) unless wshp_sched.nil?

        unless wshp_sa_clg_si.nil?
          optionalDouble = OpenStudio::OptionalDouble.new(wshp_sa_clg_si)
          wshp.setSupplyAirFlowRateDuringCoolingOperation(optionalDouble)
        end

        unless wshp_sa_htg_si.nil?
          optionalDouble = OpenStudio::OptionalDouble.new(wshp_sa_htg_si)
          wshp.setSupplyAirFlowRateDuringHeatingOperation(optionalDouble)
        end

        unless wshp_sa_no_load_si.nil?
          optionalDouble = OpenStudio::OptionalDouble.new(wshp_sa_no_load_si)
          wshp.setSupplyAirFlowRateWhenNoCoolingorHeatingisNeeded(optionalDouble)
        end

        unless wshp_oa_clg_si.nil?
          optionalDouble = OpenStudio::OptionalDouble.new(wshp_oa_clg_si)
          wshp.setOutdoorAirFlowRateDuringCoolingOperation(optionalDouble)
        end

        unless wshp_oa_htg_si.nil?
          optionalDouble = OpenStudio::OptionalDouble.new(wshp_oa_htg_si)
          wshp.setOutdoorAirFlowRateDuringHeatingOperation(optionalDouble)
        end

        unless wshp_oa_no_load_si.nil?
          optionalDouble = OpenStudio::OptionalDouble.new(wshp_oa_no_load_si)
          wshp.setOutdoorAirFlowRateWhenNoCoolingorHeatingisNeeded(optionalDouble)
        end

        wshp.setSupplyAirFanOperatingModeSchedule(wshp_fan_sched) unless wshp_fan_sched.nil?

        count_wshps += 1

        # set HC fields
        unless hc_air_flow_si.nil?
          optionalDouble = OpenStudio::OptionalDouble.new(hc_air_flow_si)
          hc.setRatedAirFlowRate(optionalDouble)
        end

        unless hc_wtr_flow_si.nil?
          optionalDouble = OpenStudio::OptionalDouble.new(hc_wtr_flow_si)
          hc.setRatedWaterFlowRate(optionalDouble)
        end

        unless hc_cap_si.nil?
          optionalDoubleCap = OpenStudio::OptionalDouble.new(hc_cap_si)
          hc.setRatedHeatingCapacity(optionalDoubleCap)
        end

        hc.setRatedHeatingCoefficientofPerformance(hc_cop) unless hc_cop.nil?

        #count_hc += 1

        # set CC fields
        cc.setRatedAirFlowRate(cc_air_flow_si) unless cc_air_flow_si.nil?
        cc.setRatedWaterFlowRate(cc_wtr_flow_si) unless cc_wtr_flow_si.nil?
        cc.setRatedTotalCoolingCapacity(cc_cap_si) unless cc_cap_si.nil? #TODO doesn't stick
        cc.setRatedSensibleCoolingCapacity(cc_sen_cap_si) unless cc_sen_cap_si.nil?
        cc.setRatedCoolingCoefficientofPerformance(cc_cop) unless cc_cop.nil?

        #count_cc += 1

        # set supplemental heating coil fields
        if sc_type.nil?
          next
        elsif sc_type == "CoilHeatingElectric" or sc_type == "CoilHeatingGas"
          optionalDoubleCap = OpenStudio::OptionalDouble.new(sc_cap_si)
          sc.setNominalCapacity(optionalDoubleCap) unless sc_cap_si.nil?
        elsif sc_type == "CoilHeatingWater"
          optionalDoubleCap = OpenStudio::OptionalDouble.new(sc_cap_si)
          sc.setRatedCapacity(optionalDoubleCap) unless sc_cap_si.nil?
        end

        #count_sc += 1

      else

        error = true

      end

    end

    # report error
    if error == true
      runner.registerError("String not found.")
    end

    # report final conditions
    runner.registerFinalCondition("Number of WSHPs changed = #{count_wshps}")

    return true

  end

end

#this allows the measure to be use by the application
SetWSHPInputs.new.registerWithApplication
