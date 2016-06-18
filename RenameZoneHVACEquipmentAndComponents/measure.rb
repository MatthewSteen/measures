# start the measure
class RenameZoneHVACEquipmentAndComponents < OpenStudio::Ruleset::ModelUserScript

  # define the name that the user will see
  def name
    return "Rename Zone HVAC Equipment And Components"
  end

  # define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    eqpt_choices = OpenStudio::StringVector.new
    eqpt_choices << "ZoneHVACFourPipeFanCoil"
    eqpt_choices << "ZoneHVACPackagedTerminalAirConditioner"
    eqpt_choices << "ZoneHVACPackagedTerminalHeatPump"
    eqpt_choices << "ZoneHVACUnitHeater"
    eqpt_choices << "ZoneHVACWaterToAirHeatPump"
    eqpt_choices << "FanZoneExhaust"
    eqpt_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("eqpt_type", eqpt_choices, true)
    eqpt_type.setDisplayName("Zone HVAC Equipment Type")
    args << eqpt_type

    rename_hvac_eqpt = OpenStudio::Ruleset::OSArgument::makeBoolArgument("rename_hvac_eqpt", false)
    rename_hvac_eqpt.setDisplayName("Rename zone HVAC equipment?")
    rename_hvac_eqpt.setDefaultValue(true)
    args << rename_hvac_eqpt

    rename_hvac_comp = OpenStudio::Ruleset::OSArgument::makeBoolArgument("rename_hvac_comp", false)
    rename_hvac_comp.setDisplayName("Rename zone HVAC equipment components?")
    rename_hvac_comp.setDefaultValue(true)
    args << rename_hvac_comp

    #TODO add optional strings for suffixes

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
    eqpt_type = runner.getStringArgumentValue("eqpt_type", user_arguments)
    rename_hvac_eqpt = runner.getBoolArgumentValue("rename_hvac_eqpt", user_arguments)
    rename_hvac_comp = runner.getBoolArgumentValue("rename_hvac_comp", user_arguments)

    # initialize variables
    count_eqpt = 0
    count_fans = 0
    count_clg_coils = 0
    count_htg_coils = 0

    # get model objects
    zones = model.getThermalZones
    fcus = model.getZoneHVACFourPipeFanCoils
    ptacs = model.getZoneHVACPackagedTerminalAirConditioners
    pthps = model.getZoneHVACPackagedTerminalHeatPumps
    uhs = model.getZoneHVACUnitHeaters
    wshps = model.getZoneHVACWaterToAirHeatPumps
    efs = model.getFanZoneExhausts

    # report initial condition
    runner.registerInitialCondition("number of thermal zones = #{zones.size}")

    # rename zone equipment and components
    zones.each do |z|

      zone_eqpt = z.equipment #vector

      zone_eqpt.each do |eqpt|

        # fan coil units
        if eqpt_type == "ZoneHVACFourPipeFanCoil" and eqpt.to_ZoneHVACFourPipeFanCoil.is_initialized

          # get equipment and components
          fcu = eqpt.to_ZoneHVACFourPipeFanCoil.get

          if fcu.supplyAirFan.to_FanOnOff.is_initialized
            fan = fcu.supplyAirFan.to_FanOnOff.get
          elsif fcu.supplyAirFan.to_FanConstantVolume.is_initialized
            fan = fcu.supplyAirFan.to_FanConstantVolume.get
          elsif fcu.supplyAirFan.to_FanVariableVolume.is_initialized
            fan = fcu.supplyAirFan.to_FanVariableVolume.get
          end

          clg_coil = fcu.coolingCoil.to_CoilCoolingWater.get
          htg_coil = fcu.heatingCoil.to_CoilHeatingWater.get

          # rename equipment
          if rename_hvac_eqpt == true
            fcu.setName("#{z.name} FCU")
            count_eqpt += 1
          end

          # rename components
          if rename_hvac_comp == true
            fan.setName("#{fcu.name} Fan")
            count_fans += 1
            clg_coil.setName("#{fcu.name} Clg Coil")
            count_clg_coils += 1
            htg_coil.setName("#{fcu.name} Htg Coil")
            count_htg_coils += 1
          end

        # packaged terminal air conditioners
        elsif eqpt_type == "ZoneHVACPackagedTerminalAirConditioner" and eqpt.to_ZoneHVACPackagedTerminalAirConditioner.is_initialized

          # get equipment and components
          ptac = eqpt.to_ZoneHVACPackagedTerminalAirConditioner.get

          if ptac.supplyAirFan.to_FanOnOff.is_initialized
            fan = ptac.supplyAirFan.to_FanOnOff.get
          elsif ptac.supplyAirFan.to_FanConstantVolume.is_initialized
            fan = ptac.supplyAirFan.to_FanConstantVolume.get
          end

          if ptac.heatingCoil.to_CoilHeatingElectric.is_initialized
            htg_coil = ptac.heatingCoil.to_CoilHeatingElectric.get
          elsif ptac.heatingCoil.to_CoilHeatingGas.is_initialized
            htg_coil = ptac.heatingCoil.to_CoilHeatingGas.get
          elsif ptac.heatingCoil.to_CoilHeatingWater.is_initialized
            htg_coil = ptac.heatingCoil.to_CoilHeatingWater.get
          end

          if ptac.coolingCoil.to_CoilCoolingDXSingleSpeed.is_initialized
            clg_coil = ptac.coolingCoil.to_CoilCoolingDXSingleSpeed.get
          elsif ptac.coolingCoil.to_CoilCoolingDXVariableSpeed.is_initialized
            clg_coil = ptac.coolingCoil.to_CoilCoolingDXVariableSpeed.get
          end

          # rename equipment
          if rename_hvac_eqpt == true
            ptac.setName("#{z.name} PTAC")
            count_eqpt += 1
          end

          # rename components
          if rename_hvac_comp == true
            fan.setName("#{ptac.name} Fan")
            count_fans += 1
            htg_coil.setName("#{ptac.name} Htg Coil")
            count_htg_coils += 1
            clg_coil.setName("#{ptac.name} Clg Coil")
            count_clg_coils += 1
          end

        # packaged terminal heat pumps
        elsif eqpt_type == "ZoneHVACPackagedTerminalHeatPump" and eqpt.to_ZoneHVACPackagedTerminalHeatPump.is_initialized

          # get equipment and components
          pthp = eqpt.to_ZoneHVACPackagedTerminalHeatPump.get

          if pthp.supplyAirFan.to_FanOnOff.is_initialized
            fan = pthp.supplyAirFan.to_FanOnOff.get
          elsif pthp.supplyAirFan.to_FanConstantVolume.is_initialized
            fan = pthp.supplyAirFan.to_FanConstantVolume.get
          end

          if pthp.heatingCoil.to_CoilHeatingDXSingleSpeed.is_initialized
            htg_coil = pthp.heatingCoil.to_CoilHeatingDXSingleSpeed.get
          elsif pthp.heatingCoil.to_CoilHeatingDXVariableSpeed.is_initialized
            htg_coil = pthp.heatingCoil.to_CoilHeatingDXVariableSpeed.get
          end

          if pthp.coolingCoil.to_CoilCoolingDXSingleSpeed.is_initialized
            clg_coil = pthp.coolingCoil.to_CoilCoolingDXSingleSpeed.get
          elsif pthp.coolingCoil.to_CoilCoolingDXVariableSpeed.is_initialized
            clg_coil = pthp.coolingCoil.to_CoilCoolingDXVariableSpeed.get
          end

          # rename equipment
          if rename_hvac_eqpt == true
            pthp.setName("#{z.name} PTHP")
            count_eqpt += 1
          end

          # rename components
          if rename_hvac_comp == true
            fan.setName("#{pthp.name} Fan")
            count_fans += 1
            htg_coil.setName("#{pthp.name} Htg Coil")
            count_htg_coils += 1
            clg_coil.setName("#{pthp.name} Clg Coil")
            count_clg_coils += 1
          end

        # unit heaters
        elsif eqpt_type == "ZoneHVACUnitHeater" and eqpt.to_ZoneHVACUnitHeater.is_initialized

          uh = eqpt.to_ZoneHVACUnitHeater.get

          if uh.supplyAirFan.to_FanOnOff.is_initialized
            fan = uh.supplyAirFan.to_FanOnOff.get
          elsif uh.supplyAirFan.to_FanConstantVolume.is_initialized
            fan = uh.supplyAirFan.to_FanConstantVolume.get
          elsif uh.supplyAirFan.to_FanVariableVolume.is_initialized
            fan = uh.supplyAirFan.to_FanVariableVolume.get
          end

          if uh.heatingCoil.to_CoilHeatingElectric.is_initialized
            htg_coil = uh.heatingCoil.to_CoilHeatingElectric.get
          elsif uh.heatingCoil.to_CoilHeatingGas.is_initialized
            htg_coil = uh.heatingCoil.to_CoilHeatingGas.get
          elsif uh.heatingCoil.to_CoilHeatingWater.is_initialized
            htg_coil = uh.heatingCoil.to_CoilHeatingWater.get
          end

          # rename equipment
          if rename_hvac_eqpt == true
            uh.setName("#{z.name} UH")
            count_eqpt += 1
          end

          # rename components
          if rename_hvac_comp == true
            fan.setName("#{uh.name} Fan")
            count_fans += 1
            htg_coil.setName("#{uh.name} Htg Coil")
            count_htg_coils += 1
          end

        # water source heat pumps
        elsif eqpt_type == "ZoneHVACWaterToAirHeatPump" and eqpt.to_ZoneHVACWaterToAirHeatPump.is_initialized

          # get equipment and components
          wshp = eqpt.to_ZoneHVACWaterToAirHeatPump.get
          fan = wshp.supplyAirFan.to_FanOnOff.get
          htg_coil = wshp.heatingCoil.to_CoilHeatingWaterToAirHeatPumpEquationFit.get
          clg_coil = wshp.coolingCoil.to_CoilCoolingWaterToAirHeatPumpEquationFit.get

          if wshp.supplementalHeatingCoil.to_CoilHeatingElectric.is_initialized
            htg_coil_supp = wshp.supplementalHeatingCoil.to_CoilHeatingElectric.get
          elsif wshp.supplementalHeatingCoil.to_CoilHeatingGas.is_initialized
            htg_coil_supp = wshp.supplementalHeatingCoil.to_CoilHeatingGas.get
          elsif wshp.supplementalHeatingCoil.to_CoilHeatingWater.is_initialized
            htg_coil_supp = wshp.supplementalHeatingCoil.to_CoilHeatingWater.get
          end

          # rename equipment
          if rename_hvac_eqpt == true
            wshp.setName("#{z.name} WSHP")
            count_eqpt += 1
          end

          # rename components
          if rename_hvac_comp == true
            fan.setName("#{wshp.name} Fan")
            count_fans += 1
            htg_coil.setName("#{wshp.name} Htg Coil")
            count_htg_coils += 1
            clg_coil.setName("#{wshp.name} Clg Coil")
            count_clg_coils += 1
            htg_coil_supp.setName("#{wshp.name} Htg Coil Backup")
            count_htg_coils += 1
          end

        end #eqpt_type loop
        
      elsif eqpt_type == "FanZoneExhaust" and eqpt.to_FanZoneExhaust.is_initialized
        
        ef = eqpt.to_FanZoneExhaust.get
        
        # rename equipment
        if rename_hvac_eqpt == true
          ef.setName("#{z.name} EF")
          count_eqpt += 1
        end
        
        # rename components
        if rename_hvac_comp == true
          nil
        end

      end #zone_eqpt loop

    end #zone loop

    # report final condition
    runner.registerInfo("number of zone equipment changed = #{count_eqpt}")
    runner.registerInfo("number of fans changed = #{count_fans}")
    runner.registerInfo("number of htg coils changed = #{count_htg_coils}")
    runner.registerInfo("number of clg coils changed = #{count_clg_coils}")

    return true

  end #run

end #measure

# this allows the measure to be used by the application
RenameZoneHVACEquipmentAndComponents.new.registerWithApplication
