require 'rails_helper'

RSpec.describe RoomsController, type: :controller do
  before do
    sign_in user
  end

  let(:valid_session) { {} }
  let(:token) { 'abc123' }
  let(:room) { Room.create(token: token) }
  let(:user) { User.create(id: 1) }

  describe "GET #show" do
    def do_request
      get :show, { :token => room.to_param }, valid_session
    end

    it "creates a participation" do
      expect {
        do_request
      }.to change{ user.participations.count }.by(1)
    end
  end
end
