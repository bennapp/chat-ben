require 'rails_helper'

RSpec.describe RatingsController, type: :controller do
  before do
    sign_in rater
  end

  let(:rater) { User.create!(id: 1, email: 'foo@bar.com', name: 'foo', password: 'saltyiest') }
  let(:ratee) { User.create!(id: 2, email: 'foo2@bar.com', name: 'foo2', password: 'saltyiest') }
  let(:rooms_post) { Post.create!(user: rater) }
  let(:room) { Room.create!(post: rooms_post) }
  let!(:rater_participation) { Participation.create(user: rater, room: room) }
  let!(:ratee_participation) { Participation.create(user: ratee, room: room) }
  let(:valid_attributes) { { value: '3', room_id: room.id.to_s, nsfw: 'f' } }

  describe "post #create" do
    def do_request
      post :create, { :rating => valid_attributes }
    end

    context "with valid params" do
      it "creates a new Rating from the ratee to rater" do
        expect {
          do_request
        }.to change(Rating, :count).by(1)
        expect(response.body).to be_blank
        expect(Rating.last.ratee_id).to eq(ratee.id)
      end
    end

    context "with an error" do
      before do
        Rating.create!(valid_attributes.merge({ rater: rater, ratee: ratee }))
      end

      it "does not create a new Rating and raises an error" do
        expect {
          do_request
        }.to raise_error ActiveRecord::RecordInvalid
        expect(response.body).to be_blank
      end
    end
  end
end
