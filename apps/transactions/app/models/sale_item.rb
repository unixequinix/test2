# == Schema Information
#
# Table name: sale_items
#
#  id                    :integer          not null, primary key
#  catalogable_id        :integer
#  catalogable_type      :string
#  quantity              :integer
#  amount                :float
#  credit_transaction_id :integer
#

class SaleItem < ActiveRecord::Base
  belongs_to :catalogable, polymorphic: true
  belongs_to :credit_transaction
end
