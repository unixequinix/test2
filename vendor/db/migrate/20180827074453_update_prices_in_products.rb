class UpdatePricesInProducts < ActiveRecord::Migration[5.1]
  def up
    Product.includes(:station).all.each do |product|
      product.destroy && next if product.price.blank?
      event = product.station.event
      product.prices[event.credit.id.to_s] = { "price" => product.price.to_f }
      product.prices[event.virtual_credit.id.to_s] =  { "price" => product.price.to_f } if event.virtual_credit.present?
      product.save
    end

    change_column :products, :price, :float, null: true
  end

  def down  
    change_column :products, :price, :float, null: false

    Product.includes(:station).each do |product|
      event = product.station.event
      product.price = product.prices.try(:[], event.credit.id.to_s).try(:[], "price")&.to_f || 0.to_f
      product.save
    end
  end
end
