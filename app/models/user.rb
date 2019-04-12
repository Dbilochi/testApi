class User < ApplicationRecord
before_create :create_confirmation_digest

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

has_secure_password


def self.new_token
    SecureRandom.urlsafe_base64
end

def authenticated(password_digest,password)
  if  BCrypt::Password.new(password_digest).is_password?(password)
    return true
  else
    return false
  end
end

# Creates and assigns the confirmation token and digest.
  def create_confirmation_digest
    self.confirmation_token  = User.new_token
  end

end
