require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { User.create(id: 1) }
  let!(:post) { Post.create(user: user) }

  describe 'soft delete' do
    it 'soft deletes' do
      expect { post.destroy }.to change { Post.count }
      expect(post).to be_paranoia_destroyed
      expect(post).to be_deleted
    end

    it 'can be deleted' do
      expect { post.really_destroy! }.to change { Post.with_deleted.count }
    end
  end
end
