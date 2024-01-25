# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :active_sessions, dependent: :destroy

  MAILER_FROM_EMIAL = "no-reply@example.com"

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  normalizes :email, with: ->(email) { email.downcase.strip }
  normalizes :unconfirmed_email, with:
    ->(unconfirmed_email) {
      return if unconfirmed_email.nil?

      self.unconfirmed_email = unconfirmed_email.downcase
    }

  generates_token_for :confirm_email, expires_in: 10.minutes do
    email
  end

  generates_token_for :reset_password, expires_in: 10.minutes do
    password_salt&.last(10)
  end

  def confirm!
    if unconfirmed_or_reconfirming?
      if unconfirmed_email.present?
        return false unless update(email: unconfirmed_email, unconfirmed_email: nil)
      end
      update_columns(confirmed_at: Time.current)
    else
      false
    end
  end

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end

  def confirmable_email
    if unconfirmed_email.present?
      unconfirmed_email
    else
      email
    end
  end

  def send_confirmation_email!
    confirmation_token = generate_token_for(:confirm_email)
    UserMailer.with(user: self, confirmation_token:).confirmation.deliver_later
  end

  def send_password_reset_email!
    password_reset_token = generate_token_for(:reset_password)
    UserMailer.with(user: self, password_reset_token:).password_reset.deliver_later
  end

  def reconfirming?
    unconfirmed_email.present?
  end

  def unconfirmed_or_reconfirming?
    unconfirmed? || reconfirming?
  end
end
