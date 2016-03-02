require 'spec_helper'

RSpec.describe RandomizrApi do

  def app
    RandomizrApi
  end

  def response_body
    JSON.parse(last_response.body)
  end

  describe "GET not existing endpoint" do
    it "returns status 404" do
      get "/"
      expect(last_response.status).to eq 404
    end
  end

  describe "GET number" do
    context "no parameters" do
      it "returns status 200 and a number from 1 to 100" do
        get "/api/number"
        expect(last_response.status).to eq 200
        expect(response_body).to include('number')
        expect(response_body['number']).to be_between(1, 100).inclusive
      end
    end

    context "max is less than min" do
      it "returns status 400" do
        get "/api/number", {'min': 10, 'max': 5}
        expect(last_response.status).to eq 400
      end
    end
  end

  describe "GET uuid" do
    it "returns status 200 and a uuid" do
      get "/api/uuid"
      expect(last_response.status).to eq 200
      expect(response_body).to include('uuid')
    end    
  end

end