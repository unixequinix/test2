class Api::V1::BannedGtagSerializer < Api::V1::BaseSerializer
  attributes :id, :reference

  def reference
    object.tag_uid
  end
end
