# start the measure
class SetPTACInputs < OpenStudio::Ruleset::ModelUserScript

  # define the name that the user will see
  def name
    return "Set PTAC Inputs"
  end

  # define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    # argument for string
		string = OpenStudio::Ruleset::OSArgument::makeStringArgument("string", false)
		string.setDisplayName("Set inputs for equipment containing the string:")
    string.setDescription("(case sensitive, leave blank for all)")
		args << string

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

    #TODO consider adding choices for ptac types: htg coil options
    '
    ZoneHVAC:PackagedTerminalAirConditioner,
        ,                        !- Name
        ,                        !- Availability Schedule Name
        ,                        !- Air Inlet Node Name
        ,                        !- Air Outlet Node Name
        ,                        !- Outdoor Air Mixer Object Type
        ,                        !- Outdoor Air Mixer Name
        ,                        !- Cooling Supply Air Flow Rate {m3/s}
        ,                        !- Heating Supply Air Flow Rate {m3/s}
        ,                        !- No Load Supply Air Flow Rate {m3/s}
        ,                        !- Cooling Outdoor Air Flow Rate {m3/s}
        ,                        !- Heating Outdoor Air Flow Rate {m3/s}
        ,                        !- No Load Outdoor Air Flow Rate {m3/s}
        ,                        !- Supply Air Fan Object Type
        ,                        !- Supply Air Fan Name
        ,                        !- Heating Coil Object Type
        ,                        !- Heating Coil Name
        ,                        !- Cooling Coil Object Type
        ,                        !- Cooling Coil Name
        DrawThrough,             !- Fan Placement
        ,                        !- Supply Air Fan Operating Mode Schedule Name
        ,                        !- Availability Manager List Name
        0;                       !- Design Specification ZoneHVAC Sizing Object Name
    '
    # PTAC arguments
    ptac_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ptac_sched", sch_handles, sch_display_names, false)
    ptac_sched.setDisplayName("PTAC: Availability Schedule Name")
    args << ptac_sched

    ptac_sa_clg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("ptac_sa_clg", false)
    ptac_sa_clg.setDisplayName("PTAC: Cooling Supply Air Flow Rate {ft3/min}")
    args << ptac_sa_clg

    ptac_sa_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("ptac_sa_htg", false)
    ptac_sa_htg.setDisplayName("PTAC: Heating Supply Air Flow Rate {ft3/min}")
    args << ptac_sa_htg

    ptac_sa_no_load = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("ptac_sa_no_load", false)
    ptac_sa_no_load.setDisplayName("PTAC: No Load Supply Air Flow Rate {ft3/min}")
    args << ptac_sa_no_load

    ptac_oa_clg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("ptac_oa_clg",false)
    ptac_oa_clg.setDisplayName("PTAC: Cooling Outdoor Air Flow Rate {ft3/min}")
    args << ptac_oa_clg

    ptac_oa_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("ptac_oa_htg",false)
    ptac_oa_htg.setDisplayName("PTAC: Heating Outdoor Air Flow Rate {ft3/min}")
    args << ptac_oa_htg

    ptac_oa_no_load = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("ptac_oa_no_load",false)
    ptac_oa_no_load.setDisplayName("PTAC: No Load Outdoor Air Flow Rate {ft3/min}")
    args << ptac_oa_no_load
'
    ptac_fan_place_choices = OpenStudio::StringVector.new
    ptac_fan_place_choices << "DrawThrough"
    ptac_fan_place_choices << ""
    ptac_fan_place = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ptac_fan_place", true)
    ptac_fan_place.setDisplayName("PTAC: Fan Placement")
    ptac_fan_place.setDefaultValue("DrawThrough")
    args << ptac_fan_place
'
    ptac_sa_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ptac_sa_sched", sch_handles, sch_display_names, false)
    ptac_sa_sched.setDisplayName("PTAC: Supply Air Fan Operating Mode Schedule Name")
    args << ptac_sa_sched
'
    Coil:Cooling:DX:SingleSpeed, v8.3
        ,                        !- Name
        ,                        !- Availability Schedule Name
        ,                        !- Gross Rated Total Cooling Capacity {W}
        ,                        !- Gross Rated Sensible Heat Ratio
        3,                       !- Gross Rated Cooling COP {W/W}
        ,                        !- Rated Air Flow Rate {m3/s}
        773.3,                   !- Rated Evaporator Fan Power Per Volume Flow Rate {W/(m3/s)}
        ,                        !- Air Inlet Node Name
        ,                        !- Air Outlet Node Name
        ,                        !- Total Cooling Capacity Function of Temperature Curve Name
        ,                        !- Total Cooling Capacity Function of Flow Fraction Curve Name
        ,                        !- Energy Input Ratio Function of Temperature Curve Name
        ,                        !- Energy Input Ratio Function of Flow Fraction Curve Name
        ,                        !- Part Load Fraction Correlation Curve Name
        ,                        !- Nominal Time for Condensate Removal to Begin {s}
        ,                        !- Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity {dimensionless}
        ,                        !- Maximum Cycling Rate {cycles/hr}
        ,                        !- Latent Capacity Time Constant {s}
        ,                        !- Condenser Air Inlet Node Name
        AirCooled,               !- Condenser Type
        0.9,                     !- Evaporative Condenser Effectiveness {dimensionless}
        ,                        !- Evaporative Condenser Air Flow Rate {m3/s}
        ,                        !- Evaporative Condenser Pump Rated Power Consumption {W}
        ,                        !- Crankcase Heater Capacity {W}
        10,                      !- Maximum Outdoor Dry-Bulb Temperature for Crankcase Heater Operation {C}
        ,                        !- Supply Water Storage Tank Name
        ,                        !- Condensate Collection Water Storage Tank Name
        ,                        !- Basin Heater Capacity {W/K}
        2,                       !- Basin Heater Setpoint Temperature {C}
        ,                        !- Basin Heater Operating Schedule Name
        ,                        !- Sensible Heat Ratio Function of Temperature Curve Name
        ,                        !- Sensible Heat Ratio Function of Flow Fraction Curve Name
        No;                      !- Report ASHRAE Standard 127 Performance Ratings
'
    # CC arguments
    cc_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_cap", false)
    cc_cap.setDisplayName("CC: Gross Rated Total Cooling Capacity {Btu/h}")
    args << cc_cap

    cc_shr = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_shr", false)
    cc_shr.setDisplayName("CC: Gross Rated Sensible Heat Ratio")
    args << cc_shr

    cc_cop = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_cop", false)
    cc_cop.setDisplayName("CC: Gross Rated Cooling COP {Btuh/Btuh}")
    args << cc_cop

    cc_air_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_air_flow", false)
    cc_air_flow.setDisplayName("CC: Rated Air Flow Rate {ft3/min}")
    args << cc_air_flow
'
    Coil:Heating:Water, v8.3
        ,                        !- Name
        ,                        !- Availability Schedule Name
        autosize,                !- U-Factor Times Area Value {W/K}
        autosize,                !- Maximum Water Flow Rate {m3/s}
        ,                        !- Water Inlet Node Name
        ,                        !- Water Outlet Node Name
        ,                        !- Air Inlet Node Name
        ,                        !- Air Outlet Node Name
        UFactorTimesAreaAndDesignWaterFlowRate,  !- Performance Input Method
        autosize,                !- Rated Capacity {W}
        82.2,                    !- Rated Inlet Water Temperature {C}
        16.6,                    !- Rated Inlet Air Temperature {C}
        71.1,                    !- Rated Outlet Water Temperature {C}
        32.2,                    !- Rated Outlet Air Temperature {C}
        0.5;                     !- Rated Ratio for Air and Water Convection
'
    # HC arguments TODO consider removing and writing separate measures since multiple types possible
    hc_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("hc_sched", sch_handles, sch_display_names, false)
    hc_sched.setDisplayName("HC: Availability Schedule Name")
    args << hc_sched

    hc_ua = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_ua", false)
    hc_ua.setDisplayName("HC: U-Factor Times Area Value {Btu/h-R}")
    args << hc_ua

    hc_wtr_flow_max = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_wtr_flow_max", false)
    hc_wtr_flow_max.setDisplayName("HC: Maximum Water Flow Rate {ft3/min}")
    args << hc_wtr_flow_max

    hc_perf_choices = OpenStudio::StringVector.new
    hc_perf_choices << "NominalCapacity"
    hc_perf_choices << "UFactorTimesAreaAndDesignWaterFlowRate"
    hc_perf = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("hc_perf", hc_perf_choices, true)
    hc_perf.setDisplayName("HC: Performance Input Method")
    hc_perf.setDefaultValue("UFactorTimesAreaAndDesignWaterFlowRate")
    args << hc_perf

    hc_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_cap", false)
    hc_cap.setDisplayName("HC: Rated Capacity {Btu/h}")
    args << hc_cap

    hc_ewt = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_ewt", false)
    hc_ewt.setDisplayName("HC: Rated Inlet Water Temperature {F}")
    args << hc_ewt

    hc_eat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_eat", false)
    hc_eat.setDisplayName("HC: Rated Inlet Air Temperature {F}")
    args << hc_eat

    hc_lwt = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_lwt", false)
    hc_lwt.setDisplayName("HC: Rated Outlet Water Temperature {F}")
    args << hc_lwt

    hc_lat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_lat", false)
    hc_lat.setDisplayName("HC: Rated Outlet Air Temperature {F}")
    args << hc_lat

    return args

  end

  #define what happens when the measure is run
  def run(model, runner, user_arguments)

    super(model, runner, user_arguments)

    #use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # get user arguments if not empty, convert to SI units for simulation
    string = runner.getOptionalStringArgumentValue("string", user_arguments)
    string = string.to_s #implicit conversion for optional string

    # get PTAC arguments
    ptac_sched = runner.getOptionalWorkspaceObjectChoiceValue("ptac_sched", user_arguments, model)
    if ptac_sched.empty?
      ptac_sched = nil
    else
      ptac_sched = ptac_sched.get.to_Schedule.get
    end

    ptac_sa_clg = runner.getOptionalDoubleArgumentValue("ptac_sa_clg", user_arguments)
    if ptac_sa_clg.empty?
      ptac_sa_clg = nil
    else
      ptac_sa_clg = ptac_sa_clg.get
      ptac_sa_clg_si = OpenStudio.convert(ptac_sa_clg, "ft^3/min", "m^3/s").get
    end

    ptac_sa_htg = runner.getOptionalDoubleArgumentValue("ptac_sa_htg", user_arguments)
    if ptac_sa_htg.empty?
      ptac_sa_htg = nil
    else
      ptac_sa_htg = ptac_sa_htg.get
      ptac_sa_htg_si = OpenStudio.convert(ptac_sa_htg, "ft^3/min", "m^3/s").get
    end

    ptac_sa_no_load = runner.getOptionalDoubleArgumentValue("ptac_sa_no_load", user_arguments)
    if ptac_sa_no_load.empty?
      ptac_sa_no_load = nil
    else
      ptac_sa_no_load = ptac_sa_no_load.get
      ptac_sa_no_load_si = OpenStudio.convert(ptac_sa_no_load, "ft^3/min", "m^3/s").get
    end

    ptac_oa_clg = runner.getOptionalDoubleArgumentValue("ptac_oa_clg", user_arguments)
    if ptac_oa_clg.empty?
      ptac_oa_clg = nil
    else
      ptac_oa_clg = ptac_oa_clg.get
      ptac_oa_clg_si = OpenStudio.convert(ptac_oa_clg, "ft^3/min", "m^3/s").get
    end

    ptac_oa_htg = runner.getOptionalDoubleArgumentValue("ptac_oa_htg", user_arguments)
    if ptac_oa_htg.empty?
      ptac_oa_htg = nil
    else
      ptac_oa_htg = ptac_oa_htg.get
      ptac_oa_htg_si = OpenStudio.convert(ptac_oa_htg, "ft^3/min", "m^3/s").get
    end

    ptac_oa_no_load = runner.getOptionalDoubleArgumentValue("ptac_oa_no_load", user_arguments)
    if ptac_oa_no_load.empty?
      ptac_oa_no_load = nil
    else
      ptac_oa_no_load = ptac_oa_no_load.get
      ptac_oa_no_load_si = OpenStudio.convert(ptac_oa_no_load, "ft^3/min", "m^3/s").get
    end

    ptac_sa_sched = runner.getOptionalWorkspaceObjectChoiceValue("ptac_sa_sched", user_arguments, model)
    if ptac_sa_sched.empty?
      ptac_sa_sched = nil
    else
      ptac_sa_sched = ptac_sa_sched.get.to_Schedule.get
    end

    # get CC arguments
    cc_cap = runner.getOptionalDoubleArgumentValue("cc_cap", user_arguments)
    if cc_cap.empty?
      cc_cap = nil
    else
      cc_cap = cc_cap.get
      cc_cap_si = OpenStudio.convert(cc_cap, "Btu/h", "W").get
    end

    cc_shr = runner.getOptionalDoubleArgumentValue("cc_shr", user_arguments)
    if cc_shr.empty?
      cc_shr = nil
    else
      cc_shr = cc_shr.get
    end

    cc_cop = runner.getOptionalDoubleArgumentValue("cc_cop", user_arguments)
    if cc_cop.empty?
      cc_cop = nil
    else
      cc_cop = cc_cop.get
    end

    cc_air_flow = runner.getOptionalDoubleArgumentValue("cc_air_flow", user_arguments)
    if cc_air_flow.empty?
      cc_air_flow = nil
    else
      cc_air_flow = cc_air_flow.get
      cc_air_flow_si = OpenStudio.convert(cc_air_flow, "ft^3/min", "m^3/s").get
    end

    # get HC arguments
    hc_sched = runner.getOptionalWorkspaceObjectChoiceValue("hc_sched", user_arguments, model)
    if hc_sched.empty?
      hc_sched = nil
    else
      hc_sched = hc_sched.get.to_Schedule.get
    end

    hc_ua = runner.getOptionalDoubleArgumentValue("hc_ua", user_arguments)
    if hc_ua.empty?
      hc_ua = nil
    else
      hc_ua = hc_ua.get
      hc_ua_si = OpenStudio.convert(hc_ua, "Btu/h*R", "W/K").get
    end

    hc_wtr_flow_max = runner.getOptionalDoubleArgumentValue("hc_wtr_flow_max", user_arguments)
    if hc_wtr_flow_max.empty?
      hc_wtr_flow_max = nil
    else
      hc_wtr_flow_max = hc_wtr_flow_max.get
      hc_wtr_flow_max_si = OpenStudio.convert(hc_wtr_flow_max, "gal/min", "m^3/s").get
    end

    hc_perf = runner.getOptionalStringArgumentValue("hc_perf", user_arguments)
    hc_perf = hc_perf.to_s #implicit conversion for optional

    hc_cap = runner.getOptionalDoubleArgumentValue("hc_cap", user_arguments)
    if hc_cap.empty?
      hc_cap = nil
    else
      hc_cap = hc_cap.get
      hc_cap_si = OpenStudio.convert(hc_cap, "Btu/h", "W").get
    end

    hc_ewt = runner.getOptionalDoubleArgumentValue("hc_ewt", user_arguments)
    if hc_ewt.empty?
      hc_ewt = nil
    else
      hc_ewt = hc_ewt.get
      hc_ewt_si = OpenStudio.convert(hc_ewt, "F", "C").get
    end

    hc_eat = runner.getOptionalDoubleArgumentValue("hc_eat", user_arguments)
    if hc_eat.empty?
      hc_eat = nil
    else
      hc_eat = hc_eat.get
      hc_eat_si = OpenStudio.convert(hc_eat, "F", "C").get
    end

    hc_lwt = runner.getOptionalDoubleArgumentValue("hc_lwt", user_arguments)
    if hc_lwt.empty?
      hc_lwt = nil
    else
      hc_lwt = hc_lwt.get
      hc_lwt_si = OpenStudio.convert(hc_lwt, "F", "C").get
    end

    hc_lat = runner.getOptionalDoubleArgumentValue("hc_lat", user_arguments)
    if hc_lat.empty?
      hc_lat = nil
    else
      hc_lat = hc_lat.get
      hc_lat_si = OpenStudio.convert(hc_lat, "F", "C").get
    end

    # get model objects
    ptacs = model.getZoneHVACPackagedTerminalAirConditioners
    htg_coils = model.getCoilHeatingWaters #model.getCoilHeatingGass model.getCoilHeatingElectrics
    clg_coils = model.getCoilCoolingDXSingleSpeeds #FUTURE model.getCoilCoolingDXVariableSpeeds

    # report initial conditions
    runner.registerInfo("Number of PTACs in the model = #{ptacs.size}")

    # initialize reporting variables
    count_ptac = 0
    count_cc = 0
    count_hc = 0
    error = false

    # set ptac inputs
    ptacs.each do |ptac|

      if string.empty? or ptac.name.to_s.include? string

        # get components
        cc = ptac.coolingCoil.to_CoilCoolingDXSingleSpeed.get

        # set PTAC fields
        ptac.setAvailabilitySchedule(ptac_sched) unless ptac_sched.nil?
        ptac.setSupplyAirFlowRateDuringCoolingOperation(ptac_sa_clg_si) unless ptac_sa_clg_si.nil?
        ptac.setSupplyAirFlowRateDuringHeatingOperation(ptac_sa_htg_si) unless ptac_sa_htg_si.nil?
        ptac.setSupplyAirFlowRateWhenNoCoolingorHeatingisNeeded(ptac_sa_no_load_si) unless ptac_sa_no_load_si #TODO not working
        runner.registerWarning("flow = #{ptac_sa_no_load}")
        ptac.setOutdoorAirFlowRateDuringCoolingOperation(ptac_oa_clg_si) unless ptac_oa_clg_si.nil?
        ptac.setOutdoorAirFlowRateDuringHeatingOperation(ptac_oa_htg_si) unless ptac_oa_htg_si.nil?
        ptac.setOutdoorAirFlowRateWhenNoCoolingorHeatingisNeeded(ptac_oa_no_load_si) unless ptac_oa_no_load_si.nil?
        ptac.setSupplyAirFanOperatingModeSchedule(ptac_sa_sched) unless ptac_sa_sched.nil?
        count_ptac += 1

        # set CC fields
        cc.setRatedTotalCoolingCapacity(cc_cap_si) unless cc_cap_si.nil?
        cc.setRatedSensibleHeatRatio(cc_shr) unless cc_shr.nil? #TODO not working
        if not cc_cop.nil?
          optional_double = OpenStudio::OptionalDouble.new(cc_cop)
          cc.setRatedCOP(optional_double)
        end
        cc.setRatedAirFlowRate(cc_air_flow_si) unless cc_air_flow_si.nil?
        count_cc += 1

        # set HC fields
        if not ptac.heatingCoil.to_CoilHeatingWater.empty?
          hc = ptac.heatingCoil.to_CoilHeatingWater.get
          hc.setAvailabilitySchedule(hc_sched) unless hc_sched.nil?
          hc.setUFactorTimesAreaValue(hc_ua_si) unless hc_ua.nil?
          hc.setMaximumWaterFlowRate(hc_wtr_flow_max_si) unless hc_wtr_flow_max.nil?
          hc.setPerformanceInputMethod(hc_perf) unless hc_perf.nil?
          hc.setRatedCapacity(hc_cap_si) unless hc_cap.nil?
          hc.setRatedInletWaterTemperature(hc_ewt_si) unless hc_ewt_si.nil?
          hc.setRatedInletAirTemperature(hc_eat_si) unless hc_eat_si.nil?
          hc.setRatedOutletWaterTemperature(hc_lwt_si) unless hc_lwt_si.nil?
          hc.setRatedOutletAirTemperature(hc_lat_si) unless hc_lat_si.nil?
          count_hc += 1
        end

      else

        error = true

      end

    end

    # report error
    if error == true
      runner.registerError("String not found.")
      return false
    end

    # report final conditions
    runner.registerWarning("Number of PTACs changed = #{count_ptac}")
    runner.registerWarning("Number of CCs changed = #{count_cc}")
    runner.registerWarning("Number of HCs changed = #{count_hc}")

    return true

  end

end

#this allows the measure to be use by the application
SetPTACInputs.new.registerWithApplication
