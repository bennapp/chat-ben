namespace :reddit do
  desc "TODO"

  task :build_channels, [:subreddits] => :environment do |t, args|
    password = begin IO.read("./redditbot").gsub("\n", "") rescue "" end
    raise 'put password in redditbot file' if password == ''
    RedditKit.sign_in 'chatbenbot', password

    subreddits = [
        { name: 'videos', domains: ['youtube.com', 'vimeo.com', 'youtu.be'] },
        { name: 'fullmoviesonyoutube', domains: ['youtube.com', 'youtu.be'] },
    ]

    if args[:subreddits].present?
      subreddit_list = args[:subreddits].split(',')
      subreddits = subreddits.select { |subreddit| subreddit_list.include?(subreddit[:name]) }
    end

    subreddits.each do |subreddit|
      links = RedditKit.links subreddit[:name], category: 'top'
      domain_links = links.select { |link| subreddit[:domains].include?(link.domain) }

      bin = Bin.where("lower(title) = ?", "/r/#{subreddit[:name]}").first
      raise "Could not find bin with matching name: #{subreddit[:name]}" if bin.nil?

      new_posts_attributes = domain_links.map { |youtube_link| {'id' => Post.create(title: youtube_link.title, link: youtube_link.url).id} }
      bin.posts_attributes = new_posts_attributes
      bin.save!
    end
  end
end
