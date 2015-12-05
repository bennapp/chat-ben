class Post < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  has_many :rooms

  validates_presence_of :user
end
