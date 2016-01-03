class Post < ActiveRecord::Base
	include ERB::Util
  acts_as_paranoid

  belongs_to :user
  has_many :rooms

  before_save :format_link_into_lightbox_html

  validates_presence_of :user

  def format_link_for_youtube
    format_link.slice!('autoplay=1&')
		format_link.sub(/640/, '320').sub(/390/, '195')
  end

  def format_link_into_lightbox_html
		return unless self.link.present?
		link = ERB::Util.html_escape(self.link)

		self.format_link = case link
			when /twitter.com/
				#<blockquote class="twitter-tweet" lang="en"><p lang="en" dir="ltr"><a href="https://twitter.com/hashtag/NewYearSamePersonBecause?src=hash">#NewYearSamePersonBecause</a> last year was only the day before yesterday, sorry to break it to you...</p>&mdash; TLBKlaus (@TLBKlaus) <a href="https://twitter.com/TLBKlaus/status/683317326654091264">January 2, 2016</a></blockquote>
				#<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
				self.format_type = 'twitter'
				"<blockquote class=\"twitter-tweet\" lang=\"en\"><a href=\"#{link}\"></a></blockquote>"
			when /imgur.com/
				#<blockquote class="imgur-embed-pub" lang="en" data-id="a/18eUC"><a href="//imgur.com/a/18eUC">Nom Award Winning Chicken Wings Recipes</a></blockquote><script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>
				self.format_type = 'imgur'
				imgur_token = link.scan(/\w{5,}/).last
				"<blockquote class=\"imgur-embed-pub\" lang=\"en\" data-id=\"#{imgur_token}\"><a href=\"//imgur.com/#{imgur_token}\"></a></blockquote>"
			when %r{youtube.com/watch?}
				youtube_token = link.scan(/v=\w{5,}/).last
				youtube_token = youtube_token.split('v=')[1]
				self.format_type = 'youtube'
				"<iframe id=\"ytplayer\" type=\"text/html\" width=\"640\" height=\"390\" src=\"http://www.youtube.com/embed/#{youtube_token}?autoplay=1&origin=https://www.chatben.co\" frameborder=\"0\"/>"
			when /vimeo.com/
				vimeo_token = URI(link).path
				vimeo_token.slice!('/channels')
				vimeo_token.slice!('/staffpicks')
				self.format_type = 'vimeo'
				"<iframe src=\"//player.vimeo.com/video#{vimeo_token}?portrait=0&color=333\" width=\"640\" height=\"390\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"
			else
			   nil
			end

		self.format_link = self.format_link.html_safe if self.format_link
  end
end
