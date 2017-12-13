require 'rails_helper'

describe Rack::Attack do
  include Rack::Test::Methods
  
  # `Rack::Attack` is configured to use the `Rails.cache` value by default,
  # but you can override that by setting the `Rack::Attack.cache.store` value
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  def app
    Rails.application
  end


  describe "throttle excessive requests by IP address" do
    let(:user) { create(:user) }
    let(:limit) { 20 }

    context "number of requests are lower than the limit" do
      it "does not change the request status" do
        limit.times do
          get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context "number of requests are higher than the limit" do
      it "changes the request status to 429" do
        (limit * 2).times do |i|
          get "/", {}, "REMOTE_ADDR" => "1.2.3.5"
          expect(last_response.status).to eq(302) if i > limit
        end
      end
    end
  end

  describe "throttle excessive GET requests to user sign in by IP address" do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
    let(:limit) { 5 }

    context "number of requests on /users/sign_in are lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          get "/users/sign_in", {}, "REMOTE_ADDR" => "1.2.3.7"
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context "number of requests on /users/sign_in are higher than the limit" do
      it "changes the request status to 429" do
        (limit * 2).times do |i|
          get "/users/sign_in", {}, "REMOTE_ADDR" => "1.2.3.9"
          expect(last_response.status).to eq(200) if i > limit
        end
      end
    end

    context "number of requests on /:event/login are lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          get "/#{event.slug}/login", {}, "REMOTE_ADDR" => "1.2.3.7"
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context "number of requests on /:event/login are higher than the limit" do
      it "changes the request status to 429" do
        (limit * 2).times do |i|
          get "/#{event.slug}/login", {}, "REMOTE_ADDR" => "1.2.3.9"
          expect(last_response.status).to eq(200) if i > limit
        end
      end
    end
  end

  describe "throttle excessive POST requests to user sign in by IP address" do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
    let(:limit) { 5 }

    context "number of requests on /users/sign_in are lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/users/sign_in", {}, "REMOTE_ADDR" => "1.2.3.8"
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context "number of requests on /users/sign_in are higher than the limit" do
      it "changes the request status to 200 because of recaptcha" do
        (limit * 2).times do |i|
          post "/users/sign_in", {}, "REMOTE_ADDR" => "1.2.3.9"
          expect(last_response.status).to eq(200) if i > limit
        end
      end
    end

    context "number of requests on /:event/login are lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/#{event.slug}/login", {}, "REMOTE_ADDR" => "1.2.3.8"
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context "number of requests on /:event/login are  higher than the limit" do
      it "changes the request status to 200 because of recaptcha" do
        (limit * 2).times do |i|
          post "/#{event.slug}/login", {}, "REMOTE_ADDR" => "1.2.3.9"
          expect(last_response.status).to eq(200) if i > limit
        end
      end
    end
  end

  describe "throttle excessive POST requests to user sign in by email address" do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
    let(:limit) { 5 }

    context "number of requests on /users/sign_in are lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/users/sign_in", { user: { login: user.email } }, "REMOTE_ADDR" => "#{i}.2.6.9"
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context "number of requests on /users/sign_in are higher than the limit" do
      it "changes the request status to 200 because of recaptcha" do
        (limit * 2).times do |i|
          post "/users/sign_in", { user: { login: user.email } }, "REMOTE_ADDR" => "#{i}.2.7.9"
          expect(last_response.status).to eq(200) if i > limit
        end
      end
    end

    context "number of requests on /:event/login are lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/#{event.slug}/login", { user: { login: user.email } }, "REMOTE_ADDR" => "#{i}.2.6.9"
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context "number of requests on /:event/login are higher than the limit" do
      it "changes the request status to 200 because of recaptcha" do
        (limit * 2).times do |i|
          post "/#{event.slug}/login", { user: { login: user.email } }, "REMOTE_ADDR" => "#{i}.2.7.9"
          expect(last_response.status).to eq(200) if i > limit
        end
      end
    end
  end
end
