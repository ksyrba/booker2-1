class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
    @books = @user.books
    @book = Book.new
    
    @today_book =  @books.created_today
    @yesterday_book = @books.created_yesterday
    @twodays_ago_book = @books.created_2days_ago
    @threedays_ago_book = @books.created_3days_ago
    @fourdays_ago_book = @books.created_4days_ago
    @fivedays_ago_book = @books.created_5days_ago
    @sixdays_ago_book = @books.created_6days_ago
    
    @this_week_book = @books.created_this_week
    @last_week_book = @books.created_last_week
    
    @currentRoomUser = RoomUser.where(user_id: current_user.id)
    @receiveUser = RoomUser.where(user_id: @user.id)
    
    unless @user.id == current_user.id
      @currentRoomUser.each do |cu|
        @receiveUser.each do |u|
          if cu.room_id == u.room_id
            @haveRoom = true
            @roomId = cu.room_id
          end
        end
      end
      unless @haveroom
        @room = Room.new
        @roomUser = RoomUser.new
      end
    end
  end

  def index
    @users = User.all
    @book = Book.new
    @books = Book.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user.id), notice: "You have updated user successfully."
    else
      render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end
end
