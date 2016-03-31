module Transactions
  class Engine < ::Rails::Engine
    initializer "model_core.factories", after: "factory_girl.set_factory_paths" do
      if defined?(FactoryGirl)
        FactoryGirl.definition_file_paths <<
          File.expand_path("#{Rails.root}/spec/transactions/factories", __FILE__)
      end
    end

    initializer :append_migrations do |app|
      return if app.root.to_s.match root.to_s
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: "../../../spec/transactions/factories"
      g.assets false
      g.helper false
    end

    config.active_record.observers = :customer_orders_observer
  end
end
