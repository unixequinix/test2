module Shared
  class Engine < ::Rails::Engine

    require 'devise'

    initializer 'shared.append_migrations' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end

    initializer 'shared.asset_precompile_paths' do |app|
      app.config.assets.precompile += ["*"]
    end
  end
end
