class UpdateCreditsPositions < ActiveRecord::Migration[5.1]
  def change
    Event.all.each do |e|
      e.credits.each do |crd|
        position = crd.type.eql?('Credit') ? 1 : 2
        crd.update(position: position)
      end
    end
  end
end
