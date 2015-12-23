class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:login]
  has_many :participations
  has_many :posts

  validates :name, :presence => true, :uniqueness => { :case_sensitive => true }
  validates_format_of :name, with: /\A[a-zA-Z0-9_\.]*\z/
  validate :validate_name

  def validate_name
    if User.where(email: name).exists?
      errors.add(:name, :invalid)
    end
  end

  attr_accessor :login

  def login=(login)
    @login = login
  end

  def login
    @login || self.name || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      conditions[:email].downcase! if conditions[:email]
      where(conditions.to_hash).first
    end
  end
end
