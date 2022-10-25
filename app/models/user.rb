class User < ApplicationRecord
  has_secure_password
  before_validation :ensure_session_token
  validates :username, 
    uniqueness: true, 
    length: { in: 3..30 }, 
    format: { without: URI::MailTo::EMAIL_REGEXP, message:  "can't be an email" }
  validates :email, 
    uniqueness: true, 
    length: { in: 3..255 }, 
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :session_token, presence: true, uniqueness: true
  validates :password, length: { in: 6..255 }, allow_nil: true

  def generate_unique_session_token
  # in a loop:
    # use SecureRandom.base64 to generate a random token
    # use `User.exists?` to check if this `session_token` is already in use
    # if already in use, continue the loop, generating a new token
    # if not in use, return the token
    loop do
      self.session_token = SecureRandom::urlsafe_base64
      if (User.exists?)
        self.session_token = SecureRandom::urlsafe_base64
      else
        return session_token
      end
    end

  end

  def ensure_session_token
    # if `self.session_token` is already present, leave it be
    # if `self.session_token` is nil, set it to `generate_unique_session_token`
    self.session_token ||= SecureRandom::urlsafe_base64
  end


  def reset_session_token!
      self.session_token = SecureRandom::urlsafe_base64
      self.save!
      self.session_token
  end

  # determine the field you need to query: 
  #   * `email` if `credential` matches `URI::MailTo::EMAIL_REGEXP`
  #   * `username` if not
  # find the user whose email/username is equal to `credential`

  # if no such user exists, return a falsey value

  # if a matching user exists, use `authenticate` to check the provided password
  # return the user if the password is correct, otherwise return a falsey value

  def self.find_by_credentials(credential, password)
    if credential.match?URI::MailTo::EMAIL_REGEXP
      user = User.find_by_email(credential)
    else
      user = User.find_by_username(credential)
    end

    if user && user.authenticate(password)
      return user
    else
      return nil
    end
  end


  def reset_session_token!
      self.session_token = SecureRandom::urlsafe_base64
      self.save!
      self.session_token
  end
end
