require 'rails_helper'

RSpec.describe "StudyRecords", type: :request do
  describe "GET /study_records" do
    it "works! (now write some real specs)" do
      get study_records_index_path
      expect(response).to have_http_status(200)
    end
  end
end
