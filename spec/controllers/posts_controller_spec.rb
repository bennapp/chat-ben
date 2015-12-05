require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:user) { User.create(id: 1) }
  let(:valid_attributes) {
    { title: 'foo', user: user }
  }
  let(:invalid_attributes) {
    { user_id: 4 }
  }
  let(:valid_session) { {} }

  describe "GET #index" do
    context "signed in" do
      before do
        sign_in user
      end

      it "assigns all posts as @posts" do
        post = Post.create! valid_attributes
        Room.create!(post: post) # Posts need rooms otherwise they don't show up
        get :index, {}, valid_session
        expect(assigns(:posts)).to eq([post])
      end

      context "order" do
        let(:some_rooms) { Post.create(user: user, title: 'some_rooms') }
        let(:fewest_rooms) { Post.create(user: user, title: 'fewest_rooms') }
        let(:most_rooms) { Post.create(user: user, title: 'most_rooms') }
        let(:no_rooms) { Post.create(user: user, title: 'no_rooms') }

        before do
          Room.create!(post: some_rooms)
          Room.create!(post: some_rooms)
          Room.create!(post: fewest_rooms)
          Room.create!(post: most_rooms)
          Room.create!(post: most_rooms)
          Room.create!(post: most_rooms)
        end

        it "orders posts by room count" do
          get :index, {}, valid_session
          expect(assigns(:posts)).to eq([most_rooms, some_rooms, fewest_rooms])
        end
      end
    end

    context "not signed in" do
      it "assigns all posts as @posts" do
        post = Post.create! valid_attributes
        Room.create!(post: post) # Posts need rooms otherwise they don't show up
        get :index, {}, valid_session
        expect(assigns(:posts)).to eq([post])
      end
    end
  end

  describe "GET #show" do
    before do
      sign_in user
    end

    it "assigns the requested post as @post" do
      post = Post.create! valid_attributes
      get :show, {:id => post.to_param}, valid_session
      expect(assigns(:post)).to eq(post)
    end

    describe "#make_make_current_user" do
      let(:post) { Post.create(user: user) }

      def do_request
        get :show, {:id => post.to_param}, valid_session
      end

      context "no rooms" do
        it "creates room" do
          expect {
            do_request
          }.to change{ Room.count }.by(1)
        end
      end

      context "two rooms" do
        let!(:old_room) { Room.create(post: post) }
        let!(:old_guy) { User.create(id: 4) }
        let!(:old_participation) { Participation.create(user: old_guy, room: old_room) }

        let!(:room2) { Room.create(post: post) }
        let!(:other_user) { User.create(id: 2) }
        let!(:other_users_friend) { User.create(id: 3) }
        let!(:participation1) { Participation.create(user: other_user, room: room2) }
        let!(:participation2) { Participation.create(user: other_users_friend, room: room2) }

        context "first empty" do
          it "should not create a new room" do
            expect {
              do_request
            }.not_to change{ Room.count }
          end

          it "should only add user to the first room" do
            expect {
              do_request
            }.not_to change{ Room.count }
            old_room.participations.pluck(:user_id) =~ [old_guy.id, user.id]
          end
        end

        context "both full" do
          let!(:old_guys_friend) { User.create(id: 4) }
          let!(:old_participation2) { Participation.create(user: old_guys_friend, room: old_room) }

          it "should create a new room" do
            expect {
              do_request
            }.to change{ Room.count }.by(1)
          end
        end
      end
    end
  end

  describe "GET #new" do
    before do
      sign_in user
    end

    it "assigns a new post as @post" do
      get :new, {}, valid_session
      expect(assigns(:post)).to be_a_new(Post)
    end
  end

  describe "GET #edit" do
    let(:post) { Post.create! valid_attributes }

    context "as the posts user" do
      before do
        sign_in user
      end

      it "assigns the requested post as @post" do
        get :edit, {:id => post.to_param}, valid_session
        expect(assigns(:post)).to eq(post)
      end
    end

    context "not as the posts user" do
      let(:other_user) { User.create(id: 2) }

      before do
        sign_in other_user
      end

      it "raises an exception" do
        expect { get :edit, {:id => post.to_param}, valid_session }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST #create" do
    before do
      sign_in user
    end

    context "with valid params" do
      it "creates a new Post" do
        expect {
          post :create, {:post => valid_attributes}, valid_session
        }.to change(Post, :count).by(1)
      end

      it "assigns a newly created post as @post for the current_user" do
        post :create, {:post => valid_attributes}, valid_session
        expect(assigns(:post)).to be_a(Post)
        expect(assigns(:post).user_id).to eq(user.id)
        expect(assigns(:post)).to be_persisted
      end

      it "redirects to the created post" do
        post :create, {:post => valid_attributes}, valid_session
        expect(response).to redirect_to(Post.last.rooms.last)
      end
    end

    # context "with invalid params" do
      # it "assigns a newly created but unsaved post as @post" do
      #   post :create, {:post => invalid_attributes}, valid_session
      #   expect(assigns(:post)).to be_a_new(Post)
      # end

      # it "re-renders the 'new' template" do
      #   post :create, {:post => invalid_attributes}, valid_session
      #   expect(response).to render_template("new")
      # end
    # end
  end

  # describe "PUT #update" do
  #   context "with valid params" do
  #     let(:new_attributes) {
  #       { title: 'I changed the title' }
  #     }
  #
  #     it "updates the requested post" do
  #       post = Post.create! valid_attributes
  #       put :update, {:id => post.to_param, :post => new_attributes}, valid_session
  #       post.reload
  #       expect(post.title).to eq(new_attributes[:title])
  #     end
  #
  #     it "assigns the requested post as @post" do
  #       post = Post.create! valid_attributes
  #       put :update, {:id => post.to_param, :post => valid_attributes}, valid_session
  #       expect(assigns(:post)).to eq(post)
  #     end
  #
  #     it "redirects to the post" do
  #       post = Post.create! valid_attributes
  #       put :update, {:id => post.to_param, :post => valid_attributes}, valid_session
  #       expect(response).to redirect_to(post)
  #     end
  #   end
  #
  #   context "with invalid params" do
  #     it "assigns the post as @post" do
  #       post = Post.create! valid_attributes
  #       put :update, {:id => post.to_param, :post => invalid_attributes}, valid_session
  #       expect(assigns(:post)).to eq(post)
  #     end
  #
  #     # it "re-renders the 'edit' template" do
  #     #   post = Post.create! valid_attributes
  #     #   put :update, {:id => post.to_param, :post => invalid_attributes}, valid_session
  #     #   expect(response).to render_template("edit")
  #     # end
  #   end
  # end

  describe "DELETE #destroy" do
    context "as the posts user" do
      before do
        sign_in user
      end

      it "destroys the requested post" do
        post = Post.create! valid_attributes
        expect {
          delete :destroy, {:id => post.to_param}, valid_session
        }.to change(Post, :count).by(-1)
      end

      it "redirects to the posts list" do
        post = Post.create! valid_attributes
        delete :destroy, {:id => post.to_param}, valid_session
        expect(response).to redirect_to(posts_url)
      end
    end

    context "not as the posts user" do
      let(:other_user) { User.create(id: 2) }

      before do
        sign_in other_user
      end

      it "raises an exception" do
        post = Post.create! valid_attributes
        expect {
          delete :destroy, {:id => post.to_param}, valid_session
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
