namespace :youtube do
  desc "TODO"

  task build_channels: :environment do
    secret_key = begin IO.read("./youtubeapi").gsub("\n", "") rescue "" end
    raise 'put password in youtube file' if secret_key == ''

    Yt.configure do |config|
      config.api_key = secret_key
      config.log_level = :debug
    end

    playlist = Yt::Playlist.new id: 'PLhHpozm-q5fdUnEP1KeN-W7v3CWrv4JZz'

    items = playlist.playlist_items
    pp items.first

    # binding.pry

    # games = [
    #   { bin_title: 'Hearthstone Streams', abbreviation: 'HS', twitch_name: 'Hearthstone: Heroes of Warcraft' },
    #   { bin_title: 'League of Legends Streams', abbreviation: 'LOLS', twitch_name: 'League of Legends' },
    #   { bin_title: 'Overwatch Streams', abbreviation: 'OVRW', twitch_name: 'Overwatch' },
    #   { bin_title: 'Counter-Strike: Global Offensive Streams', abbreviation: 'CS', twitch_name: 'Counter-Strike: Global Offensive' },
    #   { bin_title: 'Minecraft Streams', abbreviation: 'MINE', twitch_name: 'Minecraft' },
    #   { bin_title: 'Dota 2 Streams', abbreviation: 'DOTAS', twitch_name: 'Dota 2' },
    # ]
    #
    # games.each do |game|
    #   bin = Bin.find_or_create_by(title: game[:bin_title])
    #   bin.update_attribute(:abbreviation, game[:abbreviation]) if bin.abbreviation.nil?
    #
    #   streams = @twitch.streams(game: game[:twitch_name])[:body]["streams"]
    #
    #   new_post_attributes = streams.map do |stream|
    #     post_id = Post.find_or_create_by(title: "#{stream["channel"]["name"]} - #{stream["channel"]["status"]}", link: stream["channel"]["url"], bin_id: bin.id).id
    #
    #     {'id' => post_id }
    #   end
    #
    #   bin.posts_attributes = new_post_attributes
    #   bin.save!
    # end
  end
end
