namespace :reddit do
  desc "TODO"

  task :build_channels, [:subreddits] => :environment do |t, args|
    password = begin IO.read("./redditbot").gsub("\n", "") rescue "" end
    raise 'put password in redditbot file' if password == ''
    RedditKit.sign_in 'chatbenbot', password

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
    ]

    if args[:subreddits].present?
      subreddit_list = args[:subreddits].split(',')
      subreddits = subreddits.select { |subreddit| subreddit_list.include?(subreddit[:name]) }
    end

    subreddits.each do |subreddit|
      subreddit_name = subreddit[:name].gsub('/r/', '')
      links = RedditKit.links subreddit_name, category: 'hot'
      domain_links = links.select { |link| subreddit[:domains].include?(link.domain) }

      bin = Bin.find_or_create_by(title: subreddit[:name])
      bin.update_attribute(:abbreviation, subreddit[:abbreviation]) unless bin.abbreviation == subreddit[:abbreviation]

      new_posts_attributes = domain_links.map do |youtube_link|
        post = Post.find_or_create_by(title: youtube_link.title, link: youtube_link.url)
        {'id' => post.id}
      end

      bin.posts_attributes = new_posts_attributes
      bin.save!
    end
  end
end
