# start the measure
class RenameSpacesBasedOnThermalZoneNames < OpenStudio::Ruleset::ModelUserScript

  # define the name that a user will see
  def name
    return "Rename Spaces Based On Thermal Zone Names"
  end

  # define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    rename = OpenStudio::Ruleset::OSArgument::makeBoolArgument("rename", true)
    rename.setDisplayName("Rename spaces with common thermal zone?")
    rename.setDescription("Spaces will be renamed sequentially.")
    rename.setDefaultValue(false)
    args << rename

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
    rename = runner.getBoolArgumentValue("rename", user_arguments)

    # initialize variables
    rename_count = 0

    # get model objects
    zones = model.getThermalZones

    # report initial condition
    runner.registerInitialCondition("number of spaces in model = #{model.getSpaces.size}")

    # rename spaces based on zone name
    zones.each do |z|

      spaces = z.spaces

      if spaces.size == 1 or rename == true
        spaces.each do |s|
          initial_name = s.name.to_s
          s.setName(z.name.to_s)
          final_name = s.name.to_s
          runner.registerInfo("#{initial_name} renamed to #{final_name}")
          rename_count += 1
        end
      elsif spaces.size > 1 and rename == false
        runner.registerWarning("thermal zone has multiple spaces: #{z.name}")
      else
        runner.registerWarning("thermal zone does not have any spaces: #{z.name}")
      end

    end

    # report final condition
    runner.registerFinalCondition("number of spaces renamed = #{rename_count}")

    return true

  end

end

# register the measure to be used by the application
RenameSpacesBasedOnThermalZoneNames.new.registerWithApplication
