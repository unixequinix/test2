require 'boot_inquirer'

Rails.application.routes.draw do
  BootInquirer.each_active_app do |app|
    mount app.engine => '/', as: app.gem_name
  end
end
