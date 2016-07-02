namespace :youtube do
  desc "TODO"

  task build_playlists: :environment do
    secret_key = begin IO.read("./youtubeapi").gsub("\n", "") rescue "" end
    raise 'put password in youtube file' if secret_key == ''

    Yt.configure do |config|
      config.api_key = secret_key
    end

    playlists = [
      { yt_id: 'PLhHpozm-q5fdUnEP1KeN-W7v3CWrv4JZz', bin_title: 'Seinfeld Clips', abbreviation: 'SEINFELD' },
      { yt_id: 'PLAzrgbu8gEMIIK3r4Se1dOZWSZzUSadfZ', bin_title: 'Hot Ones', abbreviation: 'HOTONES' },
      { yt_id: 'PLjrhosP-Fp_qleAhpQhvJJS-yzik4lK6A', bin_title: 'H3H3Productions', abbreviation: 'H3H3' },
    ]

    playlists.each do |playlist|
      bin = Bin.find_or_create_by(title: playlist[:bin_title])
      bin.update_attribute(:abbreviation, playlist[:abbreviation]) if bin.abbreviation.nil?

      items = Yt::Playlist.new(id: playlist[:yt_id]).playlist_items

      new_post_ids = items.map do |item|
        Post.find_or_create_by(title: item.title, link: "https://www.youtube.com/watch?v=#{item.video_id}", bin_id: bin.id).id
      end

      exisiting_ids = bin.posts.order('post_bins.position asc').pluck('posts.id')
      new_post_attributes = new_post_ids.concat(exisiting_ids).uniq.map { |post_id| {'id' => post_id } }

      bin.posts_attributes = new_post_attributes
      bin.save!
    end
  end

  task build_channels: :environment do
    secret_key = begin IO.read("./youtubeapi").gsub("\n", "") rescue "" end
    raise 'put password in youtube file' if secret_key == ''

    Yt.configure do |config|
      config.api_key = secret_key
    end

    channels = [
      { channel_id: 'UCsXVk37bltHxD1rDPwtNM8Q', bin_title: 'Kurzgesagt – In a Nutshell', abbreviation: 'NUTSHELL' },
      { channel_id: 'UCFTVNLC7ysej-sD5lkLqNGA', bin_title: 'Yuka Kinoshita', abbreviation: 'YUKAFOOD' },
      { channel_id: 'UCuPgdqQKpq4T4zeqmTelnFg', bin_title: 'kaptainkristian', abbreviation: 'KAPTKRIS' },
      { channel_id: 'UCekQr9znsk2vWxBo3YiLq2w', bin_title: 'You Suck At Cooking', abbreviation: 'USUCK' },
    ]

    channels.each do |channel|
      bin = Bin.find_or_create_by(title: channel[:bin_title])
      bin.update_attribute(:abbreviation, channel[:abbreviation]) if bin.abbreviation.nil?

      videos = Yt::Channel.new(id: channel[:channel_id]).videos

      new_post_ids = videos.map do |video|
        Post.find_or_create_by(title: video.title, link: "https://www.youtube.com/watch?v=#{video.id}", bin_id: bin.id).id
      end

      exisiting_ids = bin.posts.order('post_bins.position asc').pluck('posts.id')
      new_post_attributes = new_post_ids.concat(exisiting_ids).uniq.map { |post_id| {'id' => post_id } }

      bin.posts_attributes = new_post_attributes
      bin.save!
    end
  end
end
