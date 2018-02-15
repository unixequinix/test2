class UnifyPokeSource < ActiveRecord::Migration[5.1]
  def change
    Poke.where(source: %w[admin_panel customer_portal]).update_all(source: "online")
  end
end
