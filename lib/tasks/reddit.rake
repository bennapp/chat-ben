namespace :reddit do
  desc "TODO"

  task :build_channels, [:subreddits] => :environment do |t, args|
    client = authenticated_client

    subreddits = [
        { name: '/r/Videos', domains: ['youtube.com', 'vimeo.com', 'youtu.be'], abbreviation: 'RVIDS' },
        { name: '/r/FullMoviesOnYouTube', domains: ['youtube.com', 'youtu.be'], abbreviation: 'FMOYT' },
        { name: '/r/360video', domains: ['youtube.com', 'youtu.be'], abbreviation: 'V360' },
        { name: '/r/ObscureMedia', domains: ['youtube.com', 'youtu.be'], abbreviation: 'OM' },
        { name: '/r/Unexpected', domains: ['youtube.com', 'youtu.be', 'i.imgur.com', 'imgur.com'], abbreviation: 'U!' },
        { name: '/r/YoutubeHaiku', domains: ['youtube.com', 'youtu.be'], abbreviation: 'YH' },
        { name: '/r/ArtisanVideos', domains: ['youtube.com', 'youtu.be', 'vimeo.com'], abbreviation: 'AV' },
        { name: '/r/curiousvideos', domains: ['youtube.com', 'youtu.be', 'vimeo.com'], abbreviation: 'CV' },
        { name: '/r/cookingvideos', domains: ['youtube.com', 'youtu.be', 'vimeo.com'], abbreviation: 'COOK' },
        { name: '/r/Lectures', domains: ['youtube.com', 'youtu.be', 'vimeo.com'], abbreviation: 'LCTR' },
        { name: '/r/Documentaries', domains: ['youtube.com', 'youtu.be', 'vimeo.com'], abbreviation: 'DOC' },
        { name: '/r/WoahTube', domains: ['youtube.com', 'youtu.be', 'vimeo.com'], abbreviation: 'WT' },
    ]

    if args[:subreddits].present?
      subreddit_list = args[:subreddits].split(',')
      subreddits = subreddits.select { |subreddit| subreddit_list.include?(subreddit[:name]) }
    end

    link_data = []

    subreddits.each do |subreddit|
      subreddit_name = subreddit[:name].gsub('/r/', '')
      links = client.links subreddit_name, category: 'hot'
      domain_links = links.select { |link| subreddit[:domains].include?(link.domain) }

      bin = Bin.find_or_create_by(title: subreddit[:name])
      bin.update_attribute(:abbreviation, subreddit[:abbreviation]) unless bin.abbreviation == subreddit[:abbreviation]

      new_posts_attributes = domain_links.each_with_index.map do |domain_link, index|
        post = Post.find_or_create_by(title: domain_link.title, link: domain_link.url)
        link_data << {link: domain_link, post: post, subreddit_name: subreddit[:name], bin: bin} if index < 3

        {'id' => post.id}
      end

      bin.posts_attributes = new_posts_attributes
      bin.save!
    end

    link_data.each_with_index do |link_info, index|
      begin
        client.submit_comment(link_info[:link], comment_text(link_info[:bin], link_info[:post], link_data.pluck(:post), link_info[:subreddit_name]))
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

Other posts from /r/Videos on the same channel

#{post_list.join("\n")}

I am a bot putting the top posts of #{subreddit_name} onto channels on [chatben.tv](https://chatben.tv) where you can video chat with friends!
*****
[Full /r/Videos Channel](https://chatben.tv/bins/#{bin.id}) | [More Info](https://www.reddit.com/r/chatben/wiki/chatbenbot)
    COMMENT
  end
end
