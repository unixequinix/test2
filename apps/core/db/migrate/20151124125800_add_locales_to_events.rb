class AddLocalesToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    include FlagShihTzu
    has_flags 1 => :english,
              2 => :spanish,
              3 => :italian,
              column: 'locales'
  end

  def change
    add_column :events, :locales, :integer, null: false, default: 1
  end
end
