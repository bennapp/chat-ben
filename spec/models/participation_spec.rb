require 'rails_helper'

RSpec.describe Participation, type: :model do
  let(:post) { Post.create }
  let(:user) { User.create(id: 1) }
  let(:room) { Room.create(post: post, id: 1) }
  let!(:participation) { Participation.create(room: room, user: user) }

  describe 'validations' do
    subject { participation }

    it { should be_valid }

    context 'without a room' do
      before do
        participation.room = nil
      end

      it { should_not be_valid }
    end

    context 'without a user' do
      before do
        participation.user = nil
      end

      it { should_not be_valid }
    end

    context 'two per room' do
      let(:other_user) { User.create(id: 2) }

      context 'adding one to a room with one' do
        it 'should be valid' do
          expect(Participation.create(room: room, user: other_user)).to be_valid
        end
      end

      context 'adding one to a room with two' do
        let(:third_user) { User.create(id: 3) }

        it 'should not be valid' do
          expect(Participation.create(room: room, user: other_user)).to be_valid
          expect(Participation.create(room: room, user: third_user)).not_to be_valid
        end
      end
    end
  end

  describe 'soft delete' do
    it 'soft deletes' do
      expect { participation.destroy }.to change { Participation.count }
      expect(participation).to be_paranoia_destroyed
      expect(participation).to be_deleted
    end

    it 'can be deleted' do
      expect { participation.really_destroy! }.to change { Participation.with_deleted.count }
    end

    context 'last participation in a room' do
      it 'soft deletes the room' do
        expect(participation.room.participations.count).to eq(1)
        expect { participation.destroy }.to change { Room.count }.by(-1)
      end
    end
  end
end
