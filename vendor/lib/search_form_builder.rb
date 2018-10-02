# Class that creates the serch forms
class SearchFormBuilder < SimpleForm::FormBuilder
  # Return the the input configuration for the field in the search form
  def input(attribute_name, options = {}, &block)
    options[:required] = false if options[:required] != true
    super
  end
end
