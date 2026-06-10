require 'rails_helper'

RSpec.describe "SleepRecords", type: :request do
  describe "GET /sleep_records" do
    it "works! (now write some real specs)" do
      get sleep_records_index_path
      expect(response).to have_http_status(200)
    end
  end
end
