class User < ApplicationRecord
  attr_accessor :activation_token

  before_save   :downcase_email
  before_create :create_activation_digest

  has_many :categories, dependent: :destroy
  has_many :tasks, through: :categories, dependent: :destroy

  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :name,     presence: true
  validates :password, presence: true,
                       length: { minimum: 8 },
                       allow_nil: true  # editフォームのパスワード欄を空欄でもupdate可能にする
  validates :email,    presence: true,
                       uniqueness: true,
                       format: { with: VALID_EMAIL_REGEX }

  before_save { self.email = email.downcase }

  enum role: {
    '管理': 0,
    '一般': 1
  }

  def activate
    update(activated: true, activated_at: Time.zone.now)
  end

  # トークンがダイジェストに一致したらtrue
  def authenticated?(token)
    digest = self.activation_digest
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_digest
    self.activation_token  = Security.new_token
    self.activation_digest = Security.digest(activation_token)
  end
end
