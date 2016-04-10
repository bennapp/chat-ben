class Post < ActiveRecord::Base
  include ERB::Util
  # acts_as_paranoid
  scope :without_deleted, -> { where(deleted_at: nil) }
  scope :with_deleted, -> { where.not(deleted_at: nil) }
  # end acts_as_paranoid

  scope :from_three_weeks_ago, -> { where('posts.created_at > ?', 2.weeks.ago.utc) }
  # Change back after chat ben night
  # scope :from_three_weeks_ago, -> { where('posts.created_at > ?', 2.days.ago.utc) }

  belongs_to :user
  has_many :rooms
  has_many :likes

  before_save :format_link_into_lightbox_html

  validates_presence_of :user
  validates_presence_of :title

  after_create :broadcast_create
  after_create :create_like

  def create_like
    Like.create(user_id: user_id, post_id: self.id)
  end

  def like_count
    likes.pluck(:dislike).sum { |dislike| dislike ? -1 : 1 }
  end

  def sort_order
    [-num_waiting, (sticky? ? -1 : 1), -like_count]
  end

  def destroy
    updated = update_attribute(:deleted_at, current_time_from_proper_timezone)
    ActionCable.server.broadcast("post_channel", { id: id, action: 'destroy' }) if updated
    updated
  end

  def broadcast_create
    ActionCable.server.broadcast("post_channel", { id: id, title: title, action: 'create', user: user.name })
  end

  def num_chatted
    @num_chatted ||= Participation.joins(:room).joins('inner join posts on rooms.post_id = posts.id').where('posts.id = ?', id).count
  end

  def num_waiting
    @num_waiting = rooms.where(waiting: true).where(full: false).count
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
        youtube_token = link.scan(/v=\w{5,}/).last
        youtube_token = youtube_token.split('v=')[1]
        return unless youtube_token

        self.format_type = 'youtube'
        self.format_link = youtube_token
      when /vimeo.com/
        vimeo_token = URI(link).path
        vimeo_token.slice!('/channels')
        vimeo_token.slice!('/staffpicks')
        return unless vimeo_token

        self.format_type = 'vimeo'
        self.format_link = vimeo_token
      end

    self.format_link = self.format_link.html_safe if self.format_link
  end
end
