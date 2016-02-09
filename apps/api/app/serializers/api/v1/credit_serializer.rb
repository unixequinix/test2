class Api::V1::CreditSerializer < Api::V1::BaseSerializer
  attributes :id, :value, :standard, :currency
end
