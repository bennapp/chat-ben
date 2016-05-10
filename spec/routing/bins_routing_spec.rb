require "rails_helper"

RSpec.describe BinsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/bins").to route_to("bins#index")
    end

    it "routes to #new" do
      expect(:get => "/bins/new").to route_to("bins#new")
    end

    it "routes to #show" do
      expect(:get => "/bins/1").to route_to("bins#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/bins/1/edit").to route_to("bins#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/bins").to route_to("bins#create")
    end

    it "routes to #update" do
      expect(:put => "/bins/1").to route_to("bins#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/bins/1").to route_to("bins#destroy", :id => "1")
    end

  end
end
