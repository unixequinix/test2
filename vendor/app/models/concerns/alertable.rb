module Alertable
  extend ActiveSupport::Concern

  included do
    has_many :alerts, as: :subject, dependent: :destroy
  end
end
