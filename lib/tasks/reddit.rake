namespace :reddit do
  desc "TODO"

  task :build_channels, [:subreddits] => :environment do |t, args|
    client = authenticated_client

    supported_domains = ['youtube.com', 'youtu.be', 'vimeo.com', 'twitter', 'i.imgur.com', 'imgur.com', 'twitch.tv']

    subreddits = [
        { name: '/r/Videos', abbreviation: 'RVIDS' },
        { name: '/r/FullMoviesOnYouTube', abbreviation: 'FMOYT' },
        { name: '/r/360video', abbreviation: 'V360' },
        { name: '/r/ObscureMedia', abbreviation: 'OM' },
        { name: '/r/Unexpected', abbreviation: 'U!' },
        { name: '/r/YoutubeHaiku', abbreviation: 'YH' },
        { name: '/r/ArtisanVideos', abbreviation: 'AV' },
        { name: '/r/curiousvideos', abbreviation: 'CV' },
        { name: '/r/cookingvideos', abbreviation: 'COOK' },
        { name: '/r/Lectures', abbreviation: 'LCTR' },
        { name: '/r/Documentaries', abbreviation: 'DOC' },
        { name: '/r/WoahTube', abbreviation: 'WT' },
        { name: '/r/Dota2', abbreviation: 'DOTA' },
        { name: '/r/LeagueOfLegends', abbreviation: 'LOL' },
        { name: '/r/LOLStreams', abbreviation: 'LOLS' },
        { name: '/r/DeepIntoYouTube', abbreviation: 'DEEP' },
        { name: '/r/See', abbreviation: 'WEED' },
        { name: '/r/gifs', abbreviation: 'GIFS' },
        { name: '/r/woahdude', abbreviation: 'WOAH' },
        { name: '/r/trailers', abbreviation: 'TRAIL' },
        { name: '/r/HighQualityGifs', abbreviation: 'HQGFS' },
        { name: '/r/reactiongifs', abbreviation: 'RG' },
        { name: '/r/drunk', abbreviation: 'DRUNK' },
        { name: '/r/Memes', abbreviation: 'MEMES' },
        { name: '/r/EarthPorn', abbreviation: 'EP' },
        { name: '/r/PoliticalVideo', abbreviation: 'PV' },
        { name: '/r/unknownvideos', abbreviation: 'UV' },
        { name: '/r/NotTimAndEric', abbreviation: 'NTAE' },
        { name: '/r/InterdimensionalCable', abbreviation: 'IC' },
        { name: '/r/CommercialCuts', abbreviation: 'COMC' },
        { name: '/r/trees', abbreviation: 'TREES' },
    ]

    if args[:subreddits].present?
      subreddit_list = args[:subreddits].split(',')
      subreddits = subreddits.select { |subreddit| subreddit_list.include?(subreddit[:name]) }
    end

    link_data = []

    subreddits.each do |subreddit|
      subreddit_name = subreddit[:name].gsub('/r/', '')
      links = client.links subreddit_name, category: 'hot'
      domain_links = links.select { |link| supported_domains.include?(link.domain) }

      bin = Bin.find_or_create_by(title: subreddit[:name])
      bin.update_attribute(:abbreviation, subreddit[:abbreviation]) unless bin.abbreviation == subreddit[:abbreviation]

      new_posts_attributes = domain_links.each_with_index.map do |domain_link, index|
        post = Post.find_or_create_by(title: domain_link.title, link: domain_link.url)
        post.update_attribute(:reddit_link_id, domain_link.id) if post.reddit_link_id != domain_link.id
        link_data << {link: domain_link, post: post, subreddit_name: subreddit[:name], bin: bin} if index < 4

        {'id' => post.id}
      end

      bin.posts_attributes = new_posts_attributes
      bin.save!
    end

    # Commented out since Reddit Does not like our comments, needs a new strat
    if false && Rails.env.production?
      link_data.each_with_index do |link_info, index|
        begin
          next if link_info[:post].has_reddit_comment?
          link_data_from_subreddit = link_data.select { |other_link_info| other_link_info[:subreddit_name] == link_info[:subreddit_name] }
          posts_from_subreddit = link_data_from_subreddit.pluck(:post)
          comment = comment_text(link_info[:bin], link_info[:post], posts_from_subreddit, link_info[:subreddit_name])
          client.submit_comment(link_info[:link], comment)
          link_info[:post].update_attribute(:has_reddit_comment, true)
          puts "made comment #{index + 1}/#{link_data.length}"
          puts "sleeping"
          sleep 460
        rescue => e
          puts e.class
          puts e.backtrace
          puts "sleeping"
          sleep 460
          retry
        end
      end
    end
  end

  private

  def authenticated_client
    password = begin IO.read("./redditbot").gsub("\n", "") rescue "" end
    raise 'put password in redditbot file' if password == ''
    client = RedditKit::Client.new 'chatbenbot', password
    client.user_agent = 'chatbenbot'
    client
  end

  def comment_text(bin, post, posts, subreddit_name)
    post_list = (posts - [post]).each_with_index.map { |post, index| "#{index + 1}. [#{post.title}](https://chatben.tv/bins/#{bin.id}?post=#{post.id})" }

    <<-COMMENT
[Watch this post on TV with your friends!](https://chatben.tv/bins/#{bin.id}?post=#{post.id})

Other posts from #{subreddit_name} on the same channel

#{post_list.join("\n")}

I am a bot putting the top posts of #{subreddit_name} onto channels on [chatben.tv](https://chatben.tv) where you can video chat with friends!
*****
[Full #{subreddit_name} Channel](https://chatben.tv/bins/#{bin.id}) | [More Info](https://www.reddit.com/r/chatben/wiki/chatbenbot)
    COMMENT
  end
end
