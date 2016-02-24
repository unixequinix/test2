class CompanyApi::Engine < ::Rails::Engine
  initializer :append_migrations do |app|
    unless app.root.to_s.match root.to_s
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end
  end

  initializer "model_core.factories", after: "factory_girl.set_factory_paths" do
    if defined?(FactoryGirl)
      FactoryGirl.definition_file_paths <<
        File.expand_path("#{Rails.root}/spec/company_api/factories", __FILE__)
    end
  end
end
