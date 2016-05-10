require 'rails_helper'

RSpec.describe "bins/new", :type => :view do
  before(:each) do
    assign(:bin, Bin.new())
  end

  it "renders new bin form" do
    render

    assert_select "form[action=?][method=?]", bins_path, "post" do
    end
  end
end
