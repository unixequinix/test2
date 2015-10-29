module Core
  class Engine < ::Rails::Engine

    initializer "fixing Warden's position in the Rack stack" do |app|

      app.config.middleware.insert_after ActionDispatch::Flash, Warden::Manager do |config|
        config.failure_app = UnauthorizedController
        config.default_scope = :customer

        config.scope_defaults :admin, strategies: [:admin_password]
        config.scope_defaults :customer, strategies: [:customer_password, :customer_remember_me]
      end
    end

    initializer 'core.append_migrations' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end

    initializer 'core.asset_precompile_paths' do |app|
      app.config.assets.precompile += ["*"]
    end
  end
end
