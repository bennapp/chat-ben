class Participation < ActiveRecord::Base
  # acts_as_paranoid
  scope :without_deleted, -> { where(deleted_at: nil) }
  scope :with_deleted, -> { where.not(deleted_at: nil) }
  # end acts_as_paranoid

  belongs_to :room
  belongs_to :user

  after_commit :update_room_full

  def update_room_full
    room.update_attribute(:full, room.participations.count >= 2)
  end

  validates :room, presence: true
  validates :user, presence: true
end
