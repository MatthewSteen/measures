# start the measure
class ChangeOutputFileFormatsAndUnits < OpenStudio::Ruleset::WorkspaceUserScript

  # define the name that a user will see, this method may be deprecated as
  #   the display name in PAT comes from the name field in measure.xml
  def name
    return "Change Output File Formats And Units"
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Ruleset::OSArgumentVector.new

    # argument for column separator
    col_sep_choices = OpenStudio::StringVector.new
    col_sep_choices << "All"
    col_sep_choices << "Comma"
    col_sep_choices << "CommaAndHTML"
    col_sep_choices << "CommaAndXML"
    col_sep_choices << "Fixed"
    col_sep_choices << "HTML"
    col_sep_choices << "Tab"
    col_sep_choices << "TabAndHTML"
    col_sep_choices << "XML"
    col_sep_choices << "XMLAndHTML"
    col_sep = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("col_sep", col_sep_choices, true)
    col_sep.setDisplayName("Column Separator")
    col_sep.setDefaultValue("All")
    args << col_sep

    # argument for unit conversion
    unit_conv_choices = OpenStudio::StringVector.new
    unit_conv_choices << "InchPound"
    unit_conv_choices << "JtoGJ"
    unit_conv_choices << "JtoKWH"
    unit_conv_choices << "JtoMJ"
    unit_conv_choices << "None"
    unit_conv = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("unit_conv", unit_conv_choices, true)
    unit_conv.setDisplayName("Unit Conversion")
    unit_conv.setDefaultValue("InchPound")
    args << unit_conv

    return args

  end

  # define what happens when the measure is run
  def run(workspace, runner, user_arguments)

    super(workspace, runner, user_arguments)

    # use built-in error checking
    if !runner.validateUserArguments(arguments(workspace), user_arguments)
      return false
    end

    # assign user inputs to variables
    unit_conv = runner.getStringArgumentValue("unit_conv", user_arguments)
    col_sep = runner.getStringArgumentValue("col_sep", user_arguments)

    # main code block

    # remove existing objects
    workspace.getObjectsByType("OutputControl:Table:Style".to_IddObjectType).each do |object|
      workspace.removeObjects([object.handle])
    end

    # assign EnergyPlus object to string variable
    idf_object =
      "
      OutputControl:Table:Style,
        #{col_sep},					!- Column Separator
        #{unit_conv};				!- Unit Conversion
      "
    # add EnergyPlus object to model
    new_object = OpenStudio::IdfObject::load(idf_object).get
    workspace.addObject(new_object)

    return true

  end

end

# this allows the measure to be used by the application
ChangeOutputFileFormatsAndUnits.new.registerWithApplication
