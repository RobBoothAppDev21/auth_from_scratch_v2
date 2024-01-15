# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
  normalizes :email, with: ->(email) { email.downcase.strip }

  generates_token_for :confirm_email, expires_in: 10.minutes do
    email
  end

  def confirm!
    update_columns(confirmed_at: Time.current)
  end

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end
end
