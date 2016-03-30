class Rating < ActiveRecord::Base
  belongs_to :rater, class_name: 'User', foreign_key: 'rater_id'
  belongs_to :ratee, class_name: 'User', foreign_key: 'ratee_id'
  belongs_to :room

  validates :rater, presence: true
  validates :ratee, presence: true
  validate :rater_and_ratee_participated_in_room
  validates_uniqueness_of :room_id, scope: [:rater_id, :ratee_id]

  after_save :ban_ratee_after_two_nsfw

  private

  def rater_and_ratee_participated_in_room
    if rater && ratee && room && (!rater.participations.where(room: room).any? || !ratee.participations.where(room: room).any?)
      errors.add(:base, 'Non valid rating')
    end
  end

  def ban_ratee_after_two_nsfw
    ratee.update_attribute(:banned, true) if Rating.where(nsfw: true).where(ratee: ratee).count > 1
  end
end
