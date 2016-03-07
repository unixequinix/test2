# == Schema Information
#
# Table name: transaction_items
#
#  id                    :integer          not null, primary key
#  catalogable_id        :integer
#  catalogable_type      :string
#  quantity              :integer
#  amount                :float
#  credit_transaction_id :integer
#

class TransactionItem < ActiveRecord::Base
  belongs_to :catalogable, polymorphic: true
  belongs_to :credit_transaction
end
