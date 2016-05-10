require 'rails_helper'

RSpec.describe "bins/edit", :type => :view do
  before(:each) do
    @bin = assign(:bin, Bin.create!())
  end

  it "renders the edit bin form" do
    render

    assert_select "form[action=?][method=?]", bin_path(@bin), "post" do
    end
  end
end
