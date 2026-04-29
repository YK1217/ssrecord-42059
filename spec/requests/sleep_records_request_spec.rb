require 'rails_helper'

RSpec.describe "SleepRecords", type: :request do

  describe "GET /new" do
    it "returns http success" do
      get "/sleep_records/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/sleep_records/create"
      expect(response).to have_http_status(:success)
    end
  end

end
