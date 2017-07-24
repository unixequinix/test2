class StatsBase < ApplicationRecord
  establish_connection DB_STATS
  self.abstract_class = true
end
