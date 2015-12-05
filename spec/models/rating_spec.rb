require 'rails_helper'

RSpec.describe Rating, type: :model do
  let(:rater) { User.create!(id: 1, email: 'foo@bar.com', name: 'foo', password: 'saltyiest') }
  let(:ratee) { User.create!(id: 2, email: 'foo2@bar.com', name: 'foo2', password: 'saltyiest') }
  let(:post) { Post.create!(user: rater) }
  let(:room) { Room.create!(post: post) }
  let!(:rater_participation) { Participation.create(user: rater, room: room) }
  let!(:ratee_participation) { Participation.create(user: ratee, room: room) }
  let!(:rating) { Rating.create!(room: room, rater: rater, ratee: ratee) }

  describe "validations" do
    context "without rater" do
      before do
        rater.destroy
      end

      it "should not be valid" do
        expect(rating.reload).not_to be_valid
      end
    end

    context "without ratee" do
      before do
        ratee.destroy
      end

      it "should not be valid" do
        expect(rating.reload).not_to be_valid
      end
    end

    context "without room" do
      before do
        room.destroy
      end

      it "should not be valid" do
        expect(rating.reload).not_to be_valid
      end
    end

    describe "rater_and_ratee_participated_in_room" do
      context "rater did not participate" do
        before do
          rater_participation.really_destroy!
        end

        it "should not be valid" do
          expect(rating.reload).not_to be_valid
        end
      end

      context "ratee did not participate" do
        before do
          ratee_participation.really_destroy!
        end

        it "should not be valid" do
          expect(rating.reload).not_to be_valid
        end
      end
    end

    describe "validates_uniqueness_of :room_id :rater_id :ratee_id" do
      context "from rater to ratee" do
        let(:additional_rating) { Rating.new(room: room, rater: rater, ratee: ratee) }

        it "should not be valid" do
          expect(additional_rating).not_to be_valid
        end
      end

      context "from ratee to rater" do
        let(:additional_rating) { Rating.new(room: room, rater: ratee, ratee: rater) }

        it "should be valid" do
          expect(additional_rating).to be_valid
        end
      end
    end
  end
end
