class Post < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  has_many :rooms

  before_save :format_link_into_lightbox_html

  validates_presence_of :user

  def format_link_into_lightbox_html
		return unless link
		protocol = URI.parse(link).scheme
		link_without_scheme = link.slice(protocol)

		self.format_link = case link
			when /twitter.com/
				twitter_link = protocol + link_without_scheme
				"<blockquote class=\"twitter-tweet\" lang=\"en\"><a href=\"#{twitter_link}\"></a></blockquote><script async src=\"//platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>"
			when /i.imgur.com/
				imgur_token = URI(link).path
				imgur_token.slice!('/')
				"<blockquote class=\"imgur-embed-pub\" lang=\"en\" data-id=\"#{imgur_token}\"><a href=\"//imgur.com/#{imgur_token}\"></a></blockquote><script async src=\"//s.imgur.com/min/embed.js\" charset=\"utf-8\"></script>"
			when /imgur.com/
				imgur_token = URI(link).path
				imgur_token.slice!('/gallery/')
				"<blockquote class=\"imgur-embed-pub\" lang=\"en\" data-id=\"#{imgur_token}\"><a href=\"//imgur.com/#{imgur_token}\"></a></blockquote><script async src=\"//s.imgur.com/min/embed.js\" charset=\"utf-8\"></script>"
			when /youtube.com/
				youtube_token = URI(link).query
				youtube_token = youtube_token.split('v=')[1]
				"<iframe id=\"ytplayer\" type=\"text/html\" width=\"640\" height=\"390\" src=\"http://www.youtube.com/embed/#{youtube_token}?autoplay=1&origin=https://www.chatben.co\" frameborder=\"0\"/>"
			when /vimeo.com/
				vimeo_token = URI(link).path
				"<iframe src=\"//player.vimeo.com/video#{vimeo_token}?portrait=0&color=333\" width=\"640\" height=\"390\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"
			else
			   nil
			end

		self.format_link = self.format_link.html_safe
  end
end
