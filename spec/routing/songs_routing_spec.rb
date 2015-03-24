require "rails_helper"

RSpec.describe SongsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/songs").to route_to("songs#index")
    end

    it "routes to #show" do
      expect(:get => "/songs/1").to route_to("songs#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/songs").to route_to("songs#create")
    end

    it "routes to #update" do
      expect(:put => "/songs/1").to route_to("songs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/songs/1").to route_to("songs#destroy", :id => "1")
    end

  end
end
