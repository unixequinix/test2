class ChangePokeSourceDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_null :pokes, :source, false
  end
end
