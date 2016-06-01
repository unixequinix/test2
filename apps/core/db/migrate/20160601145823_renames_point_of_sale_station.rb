class RenamesPointOfSaleStation < ActiveRecord::Migration
  def change
    Station.where(category: "point_of_sales").each do |s|
      s.update!(category: "vendor")
    end
  end
end
