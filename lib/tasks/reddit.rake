namespace :reddit do
  desc "TODO"

  task :build_channels, [:subreddits] => :environment do |t, args|
    password = begin IO.read("./redditbot").gsub("\n", "") rescue "" end
    raise 'put password in redditbot file' if password == ''
    RedditKit.sign_in 'chatbenbot', password

    subreddits = [
        { name: 'videos', full_name: '/r/Videos', domains: ['youtube.com', 'vimeo.com', 'youtu.be'] },
        { name: 'fullmoviesonyoutube', full_name: '/r/FullMoviesOnYouTube', domains: ['youtube.com', 'youtu.be'] },
        { name: '360video', full_name: '/r/360video', domains: ['youtube.com', 'youtu.be'] },
    ]

    if args[:subreddits].present?
      subreddit_list = args[:subreddits].split(',')
      subreddits = subreddits.select { |subreddit| subreddit_list.include?(subreddit[:name]) }
    end

    subreddits.each do |subreddit|
      links = RedditKit.links subreddit[:name], category: 'hot'
      domain_links = links.select { |link| subreddit[:domains].include?(link.domain) }

      bin = Bin.find_or_create_by(title: subreddit[:full_name])
      raise "Could not find bin with matching name: #{subreddit[:name]}" if bin.nil?

      new_posts_attributes = domain_links.map do |youtube_link|
        post = Post.find_or_create_by(title: youtube_link.title, link: youtube_link.url)
        {'id' => post.id}
      end

      bin.posts_attributes = new_posts_attributes
      bin.save!
    end
  end
end
