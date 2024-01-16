class UserMailer < ApplicationMailer
  def confirmation
    mail to: params[:user].confirmable_email, subject: "Confirmation Instructions"
  end

  def password_reset
    mail to: params[:user].email, subject: "Password Reset Instructions"
  end
end
