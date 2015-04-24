require "search_form_builder"

# Custom simple form helpers
module CustomFormsHelper

  # Custom simple form helpers for ransack
  def search_simple_form_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(builder: SearchFormBuilder)), &block)
  end

end