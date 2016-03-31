require "rails_helper"

RSpec.describe Access, type: :model do
  it { is_expected.to validate_presence_of(:catalog_item) }
end
