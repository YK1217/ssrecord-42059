class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  has_many :study_records, dependent: :destroy
  has_many :sleep_records, dependent: :destroy

  # attr_accessor :name, :email, :password

  VALID_PASSWORD_REGEX = /\A(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+\z/

  validates :name, presence: true, length: { maximum: 10 }

  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password,
            presence: true,
            length: { minimum: 8, maximum: 128 },
            format: {
              with: VALID_PASSWORD_REGEX,
              message: 'は半角英数字のみ使用でき、英字と数字をそれぞれ1文字以上含めてください'
            },
            confirmation: true,
            if: :password_required?

  validates :password_confirmation,
            presence: true,
            if: :password_required?

  private

  def password_required?
    new_record? || password.present?
  end
end
