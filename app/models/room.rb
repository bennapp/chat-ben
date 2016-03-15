class Room < ActiveRecord::Base
  # acts_as_paranoid
  default_scope { where(deleted_at: nil) }
  scope :with_deleted, -> { where.not(deleted_at: nil) }
  # end acts_as_paranoid

  belongs_to :post
  has_many :participations

  validates_presence_of :token
  validates_uniqueness_of :token

  before_validation :base_36_encode  # Needs specs
  before_update :base_36_encode # Needs specs

  scope :active, lambda { where(updated_at: (Time.zone.now - 35.seconds)..Time.zone.now) }

  def base_36_encode
    return if token.present?
    self.token = loop do
      random_id = rand(('z' * 8).to_i(36))
      break random_id.to_s(36) unless Room.where(token: random_id.to_s(36)).first.present?
    end
  end

  def to_param
    token
  end
end
