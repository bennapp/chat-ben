class Participation < ActiveRecord::Base
  # acts_as_paranoid
  default_scope { where(deleted_at: nil) }
  scope :with_deleted, -> { where.not(deleted_at: nil) }
  # end acts_as_paranoid

  belongs_to :room
  belongs_to :user

  validates :room, presence: true
  validates :user, presence: true
end
