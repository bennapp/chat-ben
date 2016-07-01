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

      items = Yt::Playlist.new(id: playlist[:yt_id]).playlist_items

      new_post_attributes = items.map do |item|
        post_id = Post.find_or_create_by(title: item.title, link: "https://www.youtube.com/watch?v=#{item.video_id}", bin_id: bin.id).id

        {'id' => post_id }
      end

      bin.posts_attributes = new_post_attributes
      bin.save!
    end
  end
end
