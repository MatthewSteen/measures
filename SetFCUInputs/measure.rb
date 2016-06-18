# start the measure
class SetFCUInputs < OpenStudio::Ruleset::ModelUserScript

  # define the name that the user will see
  def name
    return "Set FCU Inputs"
  end

  # define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    # argument for string
		string = OpenStudio::Ruleset::OSArgument::makeStringArgument("string", false)
		string.setDisplayName("Set inputs for equipment containing the string:")
    string.setDescription("(case sensitive, leave blank for all)")
		args << string

    #TODO add autosize option?

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
    '
    ZoneHVAC:FourPipeFanCoil,
        ,                        !- Name
        ,                        !- Availability Schedule Name
        ,                        !- Capacity Control Method
        ,                        !- Maximum Supply Air Flow Rate {m3/s}
        0.33,                    !- Low Speed Supply Air Flow Ratio
        0.66,                    !- Medium Speed Supply Air Flow Ratio
        ,                        !- Maximum Outdoor Air Flow Rate {m3/s}
        ,                        !- Outdoor Air Schedule Name
        ,                        !- Air Inlet Node Name
        ,                        !- Air Outlet Node Name
        ,                        !- Outdoor Air Mixer Object Type
        ,                        !- Outdoor Air Mixer Name
        ,                        !- Supply Air Fan Object Type
        ,                        !- Supply Air Fan Name
        ,                        !- Cooling Coil Object Type
        ,                        !- Cooling Coil Name
        ,                        !- Maximum Cold Water Flow Rate {m3/s}
        ,                        !- Minimum Cold Water Flow Rate {m3/s}
        0.001,                   !- Cooling Convergence Tolerance
        ,                        !- Heating Coil Object Type
        ,                        !- Heating Coil Name
        ,                        !- Maximum Hot Water Flow Rate {m3/s}
        ,                        !- Minimum Hot Water Flow Rate {m3/s}
        0.001,                   !- Heating Convergence Tolerance
        ,                        !- Availability Manager List Name
        0;                       !- Design Specification ZoneHVAC Sizing Object Name
    '
    # fcu arguments
    fcu_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("fcu_sched", sch_handles, sch_display_names, false)
    fcu_sched.setDisplayName("FCU: Availability Schedule Name")
    args << fcu_sched

    fcu_method = nil #TODO check GUI function

    fcu_sa_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_sa_flow", false)
    fcu_sa_flow.setDisplayName("FCU: Maximum Supply Air Flow Rate {ft3/min}")
    args << fcu_sa_flow

    fcu_sa_rat_low = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_sa_rat_low", false)
    fcu_sa_rat_low.setDisplayName("FCU: Low Speed Supply Air Flow Ratio")
    args << fcu_sa_rat_low

    fcu_sa_rat_med = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_sa_rat_med", false)
    fcu_sa_rat_med.setDisplayName("FCU: Medium Speed Supply Air Flow Ratio")
    args << fcu_sa_rat_med

    fcu_oa_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_oa_flow", false)
    fcu_oa_flow.setDisplayName("FCU: Maximum Outdoor Air Flow Rate {ft3/min}")
    args << fcu_oa_flow

    fcu_oa_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("fcu_oa_sched", sch_handles, sch_display_names, false)
    fcu_oa_sched.setDisplayName("Outdoor Air Schedule Name")
    args << fcu_oa_sched

    fcu_cw_flow_max = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_cw_flow_max", false)
    fcu_cw_flow_max.setDisplayName("FCU: Maximum Cold Water Flow Rate {gal/min}")
    args << fcu_cw_flow_max

    fcu_cw_flow_min = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_cw_flow_min", false)
    fcu_cw_flow_min.setDisplayName("FCU: Minimum Cold Water Flow Rate {gal/min}")
    args << fcu_cw_flow_min

    fcu_clg_tol = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_clg_tol", false)
    fcu_clg_tol.setDisplayName("FCU: Cooling Convergence Tolerance")
    args << fcu_clg_tol

    fcu_max_hw_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_max_hw_flow", false)
    fcu_max_hw_flow.setDisplayName("FCU: Maximum Hot Water Flow Rate {gal/min}")
    args << fcu_max_hw_flow

    fcu_min_hw_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_min_hw_flow", false)
    fcu_min_hw_flow.setDisplayName("FCU: Minimum Hot Water Flow Rate {gal/min}")
    args << fcu_min_hw_flow

    fcu_htg_tol = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_htg_tol", false)
    fcu_htg_tol.setDisplayName("FCU: Heating Convergence Tolerance")
    args << fcu_htg_tol
'
Coil:Cooling:Water,
    CoilCoolingWater,        !- Name
    ,                        !- Availability Schedule Name
    autosize,                !- Design Water Flow Rate {m3/s}
    autosize,                !- Design Air Flow Rate {m3/s}
    autosize,                !- Design Inlet Water Temperature {C}
    autosize,                !- Design Inlet Air Temperature {C}
    autosize,                !- Design Outlet Air Temperature {C}
    autosize,                !- Design Inlet Air Humidity Ratio {kgWater/kgDryAir}
    autosize,                !- Design Outlet Air Humidity Ratio {kgWater/kgDryAir}
    ,                        !- Water Inlet Node Name
    ,                        !- Water Outlet Node Name
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    SimpleAnalysis,          !- Type of Analysis
    CounterFlow,             !- Heat Exchanger Configuration
    0;                       !- Condensate Collection Water Storage Tank Name
'
    # clg coil arguments
    cc_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("cc_sched", sch_handles, sch_display_names, false)
    cc_sched.setDisplayName("CC: Availability Schedule Name")
    args << cc_sched

    cc_wtr_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_wtr_flow", false)
    cc_wtr_flow.setDisplayName("CC: Design Water Flow Rate {gal/min}")
    args << cc_wtr_flow

    cc_air_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_air_flow", false)
    cc_air_flow.setDisplayName("CC: Design Air Flow Rate {GPM} ") #TODO ft3/min when issue #1365 closed
    args << cc_air_flow

    cc_ewt = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_ewt", false)
    cc_ewt.setDisplayName("CC: Design Inlet Water Temperature {F}")
    args << cc_ewt

    cc_eat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_eat", false)
    cc_eat.setDisplayName("CC: Design Inlet Air Temperature {F}")
    args << cc_eat

    cc_lat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_lat", false)
    cc_lat.setDisplayName("CC: Design Outlet Air Temperature {F}")
    args << cc_lat

    cc_humrat_in = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_humrat_in", false)
    cc_humrat_in.setDisplayName("CC: Design Inlet Air Humidity Ratio")
    args << cc_humrat_in

    cc_humrat_out = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_humrat_out", false)
    cc_humrat_out.setDisplayName("CC: Design Outlet Air Humidity Ratio")
    args << cc_humrat_out

    cc_analysis_choices = OpenStudio::StringVector.new
    cc_analysis_choices << "DetailedAnalysis"
    cc_analysis_choices << "SimpleAnalysis"
    cc_analysis = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("cc_analysis", cc_analysis_choices, true)
    cc_analysis.setDisplayName("CC: Type of Analysis")
    cc_analysis.setDefaultValue("SimpleAnalysis")
    args << cc_analysis

    cc_config_choices = OpenStudio::StringVector.new
    cc_config_choices << "CrossFlow"
    cc_config_choices << "CounterFlow"
    cc_config = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("cc_config", cc_config_choices, true)
    cc_config.setDisplayName("CC: Heat Exchanger Configuration")
    cc_config.setDefaultValue("CounterFlow")
    args << cc_config
'
Coil:Heating:Water,
    CoilHeatingWater,        !- Name
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
    # htg coil arguments
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
    hc_perf_choices << "Nominal Capacity"
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

    hc_conv_ratio = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_conv_ratio", false)
    hc_conv_ratio.setDisplayName("HC: Rated Ratio for Air and Water Convection")
    args << hc_conv_ratio

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

    # fcu arguments
    fcu_sched = runner.getOptionalWorkspaceObjectChoiceValue("fcu_sched", user_arguments, model)
    if fcu_sched.empty?
      fcu_sched = nil
    else
      fcu_sched = fcu_sched.get.to_Schedule.get
    end

    fcu_sa_flow = runner.getOptionalDoubleArgumentValue("fcu_sa_flow", user_arguments)
    if fcu_sa_flow.empty?
      fcu_sa_flow = nil
    else
      fcu_sa_flow = fcu_sa_flow.get
      fcu_sa_flow_si = OpenStudio.convert(fcu_sa_flow, "ft^3/min", "m^3/s").get
    end

    fcu_sa_rat_low = runner.getOptionalDoubleArgumentValue("fcu_sa_rat_low", user_arguments)
    if fcu_sa_rat_low.empty?
      fcu_sa_rat_low = nil
    else
      fcu_sa_rat_low = fcu_sa_rat_low.get
    end

    fcu_sa_rat_med = runner.getOptionalDoubleArgumentValue("fcu_sa_rat_med", user_arguments)
    if fcu_sa_rat_med.empty?
      fcu_sa_rat_med = nil
    else
      fcu_sa_rat_med = fcu_sa_rat_med.get
    end

    fcu_oa_flow = runner.getOptionalDoubleArgumentValue("fcu_oa_flow", user_arguments)
    if fcu_oa_flow.empty?
      fcu_oa_flow = nil
    else
      fcu_oa_flow = fcu_oa_flow.get
      fcu_oa_flow_si = OpenStudio.convert(fcu_oa_flow, "ft^3/min", "m^3/s").get
    end

    fcu_oa_sched = runner.getOptionalWorkspaceObjectChoiceValue("fcu_oa_sched", user_arguments, model)
    if fcu_oa_sched.empty?
      fcu_oa_sched = nil
    else
      fcu_oa_sched = fcu_oa_sched.get.to_Schedule.get
    end

    fcu_cw_flow_max = runner.getOptionalDoubleArgumentValue("fcu_cw_flow_max", user_arguments)
    if fcu_cw_flow_max.empty?
      fcu_cw_flow_max = nil
    else
      fcu_cw_flow_max = fcu_cw_flow_max.get
      fcu_cw_flow_max_si = OpenStudio.convert(fcu_cw_flow_max, "gal/min", "m^3/s").get
    end

    fcu_cw_flow_min = runner.getOptionalDoubleArgumentValue("fcu_cw_flow_min", user_arguments)
    if fcu_cw_flow_min.empty?
      fcu_cw_flow_min = nil
    else
      fcu_cw_flow_min = fcu_cw_flow_min.get
      fcu_cw_flow_min_si = OpenStudio.convert(fcu_cw_flow_min, "gal/min", "m^3/s").get
    end

    fcu_clg_tol = runner.getOptionalDoubleArgumentValue("fcu_clg_tol", user_arguments)
    if fcu_clg_tol.empty?
      fcu_clg_tol = nil
    else
      fcu_clg_tol = fcu_clg_tol.get
    end

    fcu_hw_flow_max = runner.getOptionalDoubleArgumentValue("fcu_hw_flow_max", user_arguments)
    if fcu_hw_flow_max.empty?
      fcu_hw_flow_max = nil
    else
      fcu_hw_flow_max = fcu_hw_flow_max.get
      fcu_hw_flow_max_si = OpenStudio.convert(fcu_hw_flow_max, "gal/min", "m^3/s").get
    end

    fcu_hw_flow_min = runner.getOptionalDoubleArgumentValue("fcu_hw_flow_min", user_arguments)
    if fcu_hw_flow_min.empty?
      fcu_hw_flow_min = nil
    else
      fcu_hw_flow_min = fcu_hw_flow_min.get
      fcu_hw_flow_min_si = OpenStudio.convert(fcu_hw_flow_min, "gal/min", "m^3/s").get
    end

    fcu_htg_tol = runner.getOptionalDoubleArgumentValue("fcu_htg_tol", user_arguments)
    if fcu_htg_tol.empty?
      fcu_htg_tol = nil
    else
      fcu_htg_tol = fcu_htg_tol.get
    end

    # clg coil arguments
    cc_sched = runner.getOptionalWorkspaceObjectChoiceValue("cc_sched", user_arguments, model)
    if cc_sched.empty?
      cc_sched = nil
    else
      cc_sched = cc_sched.get.to_Schedule.get
    end

    cc_wtr_flow = runner.getOptionalDoubleArgumentValue("cc_wtr_flow", user_arguments)
    if cc_wtr_flow.empty?
      cc_wtr_flow = nil
    else
      cc_wtr_flow = cc_wtr_flow.get
      cc_wtr_flow_si = OpenStudio.convert(cc_wtr_flow, "gal/min", "m^3/s").get
    end

    cc_air_flow = runner.getOptionalDoubleArgumentValue("cc_air_flow", user_arguments)
    if cc_air_flow.empty?
      cc_air_flow = nil
    else
      cc_air_flow = cc_air_flow.get
      cc_air_flow_si = OpenStudio.convert(cc_air_flow, "gal/min", "m^3/s").get #TODO units
    end

    cc_ewt = runner.getOptionalDoubleArgumentValue("cc_ewt", user_arguments)
    if cc_ewt.empty?
      cc_ewt = nil
    else
      cc_ewt = cc_ewt.get
      cc_ewt_si = OpenStudio.convert(cc_ewt, "F", "C").get
    end

    cc_eat = runner.getOptionalDoubleArgumentValue("cc_eat", user_arguments)
    if cc_eat.empty?
      cc_eat = nil
    else
      cc_eat = cc_eat.get
      cc_eat_si = OpenStudio.convert(cc_eat, "F", "C").get
    end

    cc_lat = runner.getOptionalDoubleArgumentValue("cc_lat", user_arguments)
    if cc_lat.empty?
      cc_lat = nil
    else
      cc_lat = cc_lat.get
      cc_lat_si = OpenStudio.convert(cc_lat, "F", "C").get
    end

    cc_humrat_in = runner.getOptionalDoubleArgumentValue("cc_humrat_in", user_arguments)
    if cc_humrat_in.empty?
      cc_humrat_in = nil
    else
      cc_humrat_in = cc_humrat_in.get
    end

    cc_humrat_out = runner.getOptionalDoubleArgumentValue("cc_humrat_out", user_arguments)
    if cc_humrat_out.empty?
      cc_humrat_out = nil
    else
      cc_humrat_out = cc_humrat_out.get
    end

    cc_analysis = runner.getOptionalStringArgumentValue("cc_analysis", user_arguments)
    cc_analysis = cc_analysis.to_s #implicit conversion for optional

    cc_config = runner.getOptionalStringArgumentValue("cc_config", user_arguments)
    cc_config = cc_config.to_s #implicit conversion for optional

    # htg coil arguments
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

#TODO remove
    hc_conv_ratio = runner.getOptionalDoubleArgumentValue("hc_conv_ratio", user_arguments)
    if hc_conv_ratio.empty?
      hc_conv_ratio = nil
    else
      hc_conv_ratio = hc_conv_ratio.get
    end

    # initialize variables
    counter = 0
    error = false

    # get model objects
    fcus = model.getZoneHVACFourPipeFanCoils

    # report initial condition
    runner.registerInitialCondition("Number of FCUs in the model = #{fcus.size}")

    # DO STUFF

    fcus.each do |fcu|

      if string.empty? or fcu.name.to_s.include? string

        # get components
        cc = fcu.coolingCoil.to_CoilCoolingWater.get
        hc = fcu.heatingCoil.to_CoilHeatingWater.get

        # set fcu fields
        fcu.setAvailabilitySchedule(fcu_sched) unless fcu_sched.nil?
        fcu.setMaximumSupplyAirFlowRate(fcu_sa_flow_si) unless fcu_sa_flow.nil?
        fcu.setLowSpeedSupplyAirFlowRatio(fcu_sa_rat_low) unless fcu_sa_rat_low.nil?
        fcu.setMediumSpeedSupplyAirFlowRatio(fcu_sa_rat_med) unless fcu_sa_rat_med.nil?
        fcu.setMaximumOutdoorAirFlowRate(fcu_oa_flow_si) unless fcu_oa_flow.nil?
        fcu.setOutdoorAirSchedule(fcu_oa_sched) unless fcu_oa_sched.nil?
        fcu.setMaximumColdWaterFlowRate(fcu_cw_flow_max_si) unless fcu_cw_flow_max.nil?
        fcu.setMinimumColdWaterFlowRate(fcu_cw_flow_min_si) unless fcu_cw_flow_min.nil?
        fcu.setCoolingConvergenceTolerance(fcu_clg_tol) unless fcu_clg_tol.nil?
        fcu.setMaximumHotWaterFlowRate(fcu_hw_flow_max_si) unless fcu_hw_flow_max_si.nil?
        fcu.setMinimumHotWaterFlowRate(fcu_hw_flow_min_si) unless fcu_hw_flow_min_si.nil?
        fcu.setHeatingConvergenceTolerance(fcu_htg_tol) unless fcu_htg_tol.nil?

        # set CC fields
        cc.setAvailabilitySchedule(cc_sched) unless cc_sched.nil?
        cc.setDesignWaterFlowRate(cc_wtr_flow_si) unless cc_wtr_flow.nil?
        cc.setDesignAirFlowRate(cc_air_flow_si) unless cc_air_flow.nil?
        cc.setDesignInletWaterTemperature(cc_ewt_si) unless cc_ewt_si.nil?
        cc.setDesignInletAirTemperature(cc_eat_si) unless cc_eat_si.nil?
        cc.setDesignOutletAirTemperature(cc_lat_si) unless cc_lat_si.nil?
        cc.setDesignInletAirHumidityRatio(cc_humrat_in) unless cc_humrat_in.nil?
        cc.setDesignOutletAirHumidityRatio(cc_humrat_out) unless cc_humrat_out.nil?
        cc.setTypeOfAnalysis(cc_analysis) unless cc_analysis.nil?
        cc.setHeatExchangerConfiguration(cc_config) unless cc_config.nil?

        # set HC fields
        hc.setAvailabilitySchedule(hc_sched) unless hc_sched.nil?
        hc.setUFactorTimesAreaValue(hc_ua_si) unless hc_ua.nil?
        hc.setMaximumWaterFlowRate(hc_wtr_flow_max_si) unless hc_wtr_flow_max.nil?
        hc.setPerformanceInputMethod(hc_perf) unless hc_perf.nil?
        hc.setRatedCapacity(hc_cap_si) unless hc_cap.nil?
        hc.setRatedInletWaterTemperature(hc_ewt_si) unless hc_ewt_si.nil?
        hc.setRatedInletAirTemperature(hc_eat_si) unless hc_eat_si.nil?
        hc.setRatedOutletWaterTemperature(hc_lwt_si) unless hc_lwt_si.nil?
        hc.setRatedOutletAirTemperature(hc_lat_si) unless hc_lat_si.nil?
        hc.setRatedRatioForAirAndWaterConvection(hc_conv_ratio) unless hc_conv_ratio.nil?

        counter += 1

      else

        error = true

      end

    end

    if error == true
      runner.registerError("String not found.")
    end

    # report final condition
    runner.registerFinalCondition("Number of FCUs changed = #{counter}")

    return true

  end #end the run method

end #end the measure

#this allows the measure to be use by the application
SetFCUInputs.new.registerWithApplication
