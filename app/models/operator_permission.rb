class OperatorPermission < CatalogItem
  has_many :operator_transactions, dependent: :destroy, foreign_key: :catalog_item_id

  belongs_to :station, optional: true

  validates :role, presence: true
  validates :station_id, presence: true, if: (-> { group.blank? })
  validates :group, presence: true, if: (-> { station_id.blank? })

  validates :station_id, absence: true, if: (-> { group.present? })
  validates :group, absence: true, if: (-> { station_id.present? })

  validates :role, uniqueness: { scope: %i[group station_id], message: (->(object, _data) { "This role has already been used for #{'group ' + object.group if object.group}#{'station ' + object.station.name if object.station}" }) } # rubocop:disable Metrics/LineLength

  enum role: { operator: 1, manager: 2 }
  enum group: { glownet: 0, checkin: 1, box_office: 2, banking: 3, vendors: 4, bars: 5, management: 6 }

  def name
    station ? "#{role.humanize} permission for #{station.name}" : "#{role.humanize} permission for #{group.humanize}"
  end
end
