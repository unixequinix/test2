module CompanyApi
  class Engine < ::Rails::Engine
    initializer "model_core.factories", after: "factory_girl.set_factory_paths" do
      if defined?(FactoryGirl)
        FactoryGirl.definition_file_paths <<
          File.expand_path("#{Rails.root}/spec/company_api/factories", __FILE__)
      end
    end
  end
end
