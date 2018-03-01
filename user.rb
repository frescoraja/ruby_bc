require 'bcrypt'

class User
  attr_reader :login
  def initialize(login, unencrypted_password)
    @login = login
    create_digest!(unencrypted_password)
  end

  def create_digest!(unencrypted_password)
    validate_password(unencrypted_password)

    @password_digest = BCrypt::Password.create(unencrypted_password)
  end

  def is_password?(unencrypted_password)
    BCrypt::Password.new(@password_digest).is_password?(unencrypted_password)
  end

  private
  def validate_password(password)
    msgs = []
    msgs << "minimum length: 8 chars" if password.length < 8
    msgs << "must include at least one upper and one lower case letter" if password.upcase == password || password.downcase == password
    msgs << "must include at least one number or special character" if (password.upcase.chars - ('A'..'Z').to_a).empty?
    msgs << "must not contain login" if !password.downcase[@login.downcase].nil?

    raise InvalidPassword.new(msgs) if !msgs.empty?
  end
end

class InvalidPassword < StandardError
  def initialize(msgs)
    output = ["Failed to pass all constraints", msgs.join(", ")].join(": ")
    super(output)
  end
end
