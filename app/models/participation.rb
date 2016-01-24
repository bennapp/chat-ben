class Participation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :room
  belongs_to :user

  validates :room, presence: true
  validates :user, presence: true

  # validate :two_per_room

  # before_destroy :destroy_empty_room

  # def destroy_empty_room
    # if room.participations.count == 1
      # room.destroy
    # end
  # end

  private

  # def two_per_room
    # errors.add(:room, 'is already full with two people') if room && room.participations.count > 2
  # end
end
