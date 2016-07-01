namespace :youtube do
  desc "TODO"

  task build_channels: :environment do
    secret_key = begin IO.read("./youtubeapi").gsub("\n", "") rescue "" end
    raise 'put password in youtube file' if secret_key == ''

    Yt.configure do |config|
      config.api_key = secret_key
    end

    playlists = [
      { yt_id: 'PLhHpozm-q5fdUnEP1KeN-W7v3CWrv4JZz', bin_title: 'Seinfeld Clips', abbreviation: 'SEINFELD' },
    ]

    playlists.each do |playlist|
      bin = Bin.find_or_create_by(title: playlist[:bin_title])
      bin.update_attribute(:abbreviation, playlist[:abbreviation]) if bin.abbreviation.nil?

      items = Yt::Playlist.new id: playlist[:yt_id]

      new_post_attributes = []

      binding.pry

      items.each do |item|
        post_id = Post.find_or_create_by(title: item.title, link: "https://www.youtube.com/watch?v=#{item.id}", bin_id: bin.id).id

        new_post_attributes << {'id' => post_id }
      end

      binding.pry

      bin.posts_attributes = new_post_attributes
      bin.save!
    end
  end
end
