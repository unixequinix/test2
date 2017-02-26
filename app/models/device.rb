class Device < ActiveRecord::Base
  before_validation :upcase_asset_tracker!

  def upcase_asset_tracker!
    asset_tracker&.upcase!
  end
end
