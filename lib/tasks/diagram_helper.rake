namespace :generate do
  desc "Generate ERD diagram"
    task :erd_diagram, [] => [:environment] do |t, args|
    require 'rails_erd/diagram/graphviz'
    Rails.application.eager_load!
    options = {}
    options[:title]    = 'Glownet web DB Diagram'
    options[:attributes]    = [:primary_keys, :foreign_keys, :inheritance, :content]
    options[:orientation]    = :horizontal
    #options[:filename] = File.join(::Rails.root, 'core/db', filename(s))
    RailsERD::Diagram::Graphviz.create(options)
  end
end