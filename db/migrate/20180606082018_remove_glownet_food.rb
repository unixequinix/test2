class RemoveGlownetFood < ActiveRecord::Migration[5.1]
  def change
    ids = (Transaction.select(:station_id).distinct.pluck(:station_id) + OperatorPermission.select(:station_id).distinct.pluck(:station_id)).uniq

    Station.where(name: "Glownet Food").where.not(id: ids).each do |station|
      station.topup_credits.delete_all
      station.destroy!
    end
  end
end
