require 'rails_helper'

RSpec.describe Seeder::SeedLoader, type: :domain_logic do
  describe 'load_default_event_parameters' do
    it 'stores in the DB all the default values for an event' do
      event = create(:event)
      number_of_parameters_before = EventParameter.count
      Seeder::SeedLoader.load_default_event_parameters(event)
      expect(EventParameter.count).to be > number_of_parameters_before
    end

    it 'does not create duplicated records' do
      event = create(:event)
      Seeder::SeedLoader.load_default_event_parameters(event)
      number_of_parameters_before = EventParameter.count
      Seeder::SeedLoader.load_default_event_parameters(event)
      expect(EventParameter.count).to eq(number_of_parameters_before)
    end
  end

  describe 'create_event_parameters' do
    it 'does not create duplicated records' do
      number_of_parameters_before = Parameter.count
      Seeder::SeedLoader.create_event_parameters
      expect(Parameter.count).to eq(number_of_parameters_before)
    end
  end

  describe 'create_claim_parameters' do
    it 'stores in the DB all the default claim parameters' do
      DatabaseCleaner.clean_with(:truncation)
      number_of_parameters_before = Parameter.count
      Seeder::SeedLoader.create_claim_parameters
      expect(Parameter.count).to be > number_of_parameters_before
    end

    it 'does not create duplicated records' do
      Seeder::SeedLoader.create_claim_parameters
      number_of_parameters_before = Parameter.count
      Seeder::SeedLoader.create_claim_parameters
      expect(Parameter.count).to eq(number_of_parameters_before)
    end
  end
end
