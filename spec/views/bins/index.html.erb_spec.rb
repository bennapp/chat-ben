require 'rails_helper'

RSpec.describe "bins/index", :type => :view do
  before(:each) do
    assign(:bins, [
      Bin.create!(),
      Bin.create!()
    ])
  end

  it "renders a list of bins" do
    render
  end
end
