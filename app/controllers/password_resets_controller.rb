class PasswordResetsController < ApplicationController
  before_action :fetch_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def edit
  end

  def update
    if params[:user][:password].empty?                  # Case (3)
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)          # Case (4)
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'                                     # Case (2)
    end
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)

    if @user
      # Create reset digest and send to user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email Address not found'
      render 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def fetch_user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    return if @user && @user.activated? &&
              @user.authenticated?(:reset, params[:id])

    redirect_to root_url
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = "Password reset has expired."
    redirect_to new_password_reset_url
  end
end
