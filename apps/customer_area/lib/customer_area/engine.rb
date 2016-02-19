module CustomerArea
  class Engine < ::Rails::Engine
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
          File.expand_path("#{Rails.root}/spec/customer_area/factories", __FILE__)
      end
    end

    initializer "customer_area.asset_precompile_paths" do |app|
      app.config.assets.precompile += ["customer.scss"]
      app.config.assets.precompile += ["customer.js"]
    end
  end
end
