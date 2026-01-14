class Radd::Record < Sequel::Model
  class << self
    def active
      exclude(ip: nil)
    end
  end

  def password=(password)
    self.password_hash = BCrypt::Password.create(password)
  end

  def validate
    super
    errors.add(:name, "is invalid") if !name || !name.match(/\A[a-z0-9]([A-z0-9_\-]*)\z/)
    errors.add(:ip,   "is invalid") if ip && !Radd.valid_ip?(ip)
  end

  def before_save
    super
    self.updated_at = Time.now
  end
end
