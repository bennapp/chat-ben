require 'rails_helper'

RSpec.describe ParticipationsController, type: :controller do
  let(:user) { User.create(id: 1) }
  let(:room) { Room.create(id: 1) }
  let!(:participation) { Participation.create(room: room, user: user) }

  describe "DELETE #destroy" do
    context "as the participant" do
      before do
        sign_in user
      end

      it "destroys the requested participation" do
        expect {
          delete :destroy, { :id => participation.to_param }
        }.to change(Participation, :count).by(-1)
      end

      it "renders nothing" do
        delete :destroy, { :id => participation.to_param }
        expect(response.body).to be_blank
      end
    end

    context "as a non participant" do
      let(:other_user) { User.create(id: 2) }

      before do
        sign_in other_user
      end

      it "raises an error as it cannot find the participation" do
        expect {
          delete :destroy, { :id => participation.to_param }
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
