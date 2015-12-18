namespace :annotate do
  desc "Annotate models"
  task :models, [] => [:environment] do |t, args|
    models = []
    models += ["#{Rails.root}/apps/core/app/models"]
    BootInquirer.each_active_app do |app|
      directory = "#{Rails.root}/apps/#{app.gem_name}/app/models"
      models += [directory] if File.directory?(directory)
    end
    system "bundle exec annotate --exclude tests,fixtures --model-dir='#{models.join(',').to_s}'"
  end
end