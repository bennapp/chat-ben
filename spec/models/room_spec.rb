require 'rails_helper'

RSpec.describe Room, type: :model do
  let(:user) { User.create(id: 1) }
  let(:post) { Post.create(user: user) }
  let!(:room) { Room.create(post: post) }

  describe 'soft delete' do
    it 'soft deletes' do
      expect { room.destroy }.to change { Room.count }
      expect(room).to be_paranoia_destroyed
      expect(room).to be_deleted
    end

    it 'can be deleted' do
      expect { room.really_destroy! }.to change { Room.with_deleted.count }
    end

    context 'last room in a post' do
      it 'soft deletes the post' do
        expect(room.post.rooms.count).to eq(1)
        expect { room.destroy }.to change { Post.count }.by(-1)
      end
    end
  end
end
