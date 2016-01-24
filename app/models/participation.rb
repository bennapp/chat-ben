class Participation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :room
  belongs_to :user

  validates :room, presence: true
  validates :user, presence: true
end
