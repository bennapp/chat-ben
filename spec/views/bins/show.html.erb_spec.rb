require 'rails_helper'

RSpec.describe "bins/show", :type => :view do
  before(:each) do
    @bin = assign(:bin, Bin.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
