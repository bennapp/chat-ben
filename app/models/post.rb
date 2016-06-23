class Post < ActiveRecord::Base
  include ERB::Util
  # acts_as_paranoid
  scope :without_deleted, -> { where(deleted_at: nil) }
  scope :with_deleted, -> { where.not(deleted_at: nil) }
  # end acts_as_paranoid

  belongs_to :user
  has_many :bins, through: :post_bins
  has_many :post_bins
  has_many :rooms
  has_many :likes
  has_many :reactions
  belongs_to :last_editor, class_name: 'User', foreign_key: 'editor_id'
  has_one :origin_bin, class_name: 'Bin', foreign_key: 'bin_id'

  before_save :format_link_into_lightbox_html

  validates_presence_of :title

  after_create :create_like

  def create_like
    Like.create(user_id: user_id, post_id: self.id)
  end

  def like_count
    likes.pluck(:dislike).sum { |dislike| dislike ? -1 : 1 }
  end

  def destroy
    update_attribute(:deleted_at, current_time_from_proper_timezone)
  end

  def id_with_title
    "#{id} - #{title}"
  end

  def full_url
    begin
      u = URI.parse(link)
      if !u.scheme
        'https://' + link
      else
        link
      end
    rescue
      ''
    end
  end

  def format_icon
    case format_type
      when 'twitter'
        'fa fa-twitter fa-lg'
      when 'imgur'
        'glyphicon glyphicon-picture'
      when 'youtube'
        'fa fa-youtube fa-lg'
      when 'vimeo'
        'fa fa-vimeo fa-lg'
      when 'twitch'
        'fa fa-twitch fa-lg'
      else
        ''
    end
  end

  def format_link_into_lightbox_html
    return unless self.link.present?
    link = ERB::Util.html_escape(self.link)

    case link
      when /twitter.com/
        self.format_type = 'twitter'
        self.format_link = link
      when /imgur.com/
        imgur_token = link.scan(/\w{5,}/).last
        return unless imgur_token

        self.format_type = 'imgur'
        self.format_link = imgur_token
      when %r{youtube.com/watch?}
        youtube_token = link.split('v=')[1]
        youtube_token = youtube_token.split('&').first
        return unless youtube_token

        start_time = link.split('t=')[1]
        start_time = start_time.split('&').first if start_time.present?

        self.format_type = 'youtube'
        self.format_link = youtube_token
        self.start_time = start_time if start_time.present?
      when /youtu.be/
        start_time = link.split('t=')[1]
        start_time = start_time.split('&').first if start_time.present?

        self.start_time = start_time if start_time.present?
        self.format_type = 'youtube'
        self.format_link = link.split('/').last
      when /vimeo.com/
        vimeo_token = URI(link).path
        vimeo_token.slice!('/channels')
        vimeo_token.slice!('/staffpicks')
        return unless vimeo_token

        self.format_type = 'vimeo'
        self.format_link = vimeo_token
      when /twitch.tv/
        self.format_type = 'twitch'
        channel = link.split('/').last
        self.format_link = channel
      when /gfycat.com/
        self.format_type = 'gfycat'
        token = link.split('gfycat.com/').last

        self.format_link = token if token.present?
      end

    self.format_link = self.format_link.html_safe if self.format_link
  end
end
