class RemoveStationParameters < ActiveRecord::Migration
  def change
    add_reference :station_products, :station
    add_reference :topup_credits, :station
    add_reference :station_catalog_items, :station
    add_reference :access_control_gates, :station

    puts "-- updating station_products station"
    sql = "UPDATE station_products SP
           SET station_id = PARAM.station_id
           FROM station_parameters PARAM
           WHERE PARAM.station_parametable_id = SP.id and PARAM.station_parametable_type = 'StationProduct';"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- updating topup_credits station"
    sql = "UPDATE topup_credits TC
           SET station_id = PARAM.station_id
           FROM station_parameters PARAM
           WHERE PARAM.station_parametable_id = TC.id and PARAM.station_parametable_type = 'TopupCredit';"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- updating station_catalog_items station"
    sql = "UPDATE station_catalog_items SCI
           SET station_id = PARAM.station_id
           FROM station_parameters PARAM
           WHERE PARAM.station_parametable_id = SCI.id and PARAM.station_parametable_type = 'StationCatalogItem';"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- updating access_control_gates station"
    sql = "UPDATE access_control_gates ACG
           SET station_id = PARAM.station_id
           FROM station_parameters PARAM
           WHERE PARAM.station_parametable_id = ACG.id and PARAM.station_parametable_type = 'AccessControlGate';"
    ActiveRecord::Base.connection.execute(sql)

    all_stations = Station.pluck(:id)

    station_products_stations = StationProduct.pluck(:station_id)
    StationProduct.where(station_id: station_products_stations - all_stations).destroy_all

    topup_credits_stations = TopupCredit.pluck(:station_id)
    TopupCredit.where(station_id: topup_credits_stations - all_stations).destroy_all

    station_catalog_items_stations = StationCatalogItem.pluck(:station_id)
    StationCatalogItem.where(station_id: station_catalog_items_stations - all_stations).destroy_all

    access_control_gates_stations = AccessControlGate.pluck(:station_id)
    AccessControlGate.where(station_id: access_control_gates_stations - all_stations).destroy_all

    add_index :station_products, :station_id
    add_index :topup_credits, :station_id
    add_index :station_catalog_items, :station_id
    add_index :access_control_gates, :station_id

    add_foreign_key :station_products, :stations
    add_foreign_key :topup_credits, :stations
    add_foreign_key :station_catalog_items, :stations
    add_foreign_key :access_control_gates, :stations
  end
end
