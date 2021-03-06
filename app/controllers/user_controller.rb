class UserController < ApplicationController
  before_filter :authenticate_user!, only: [:content, :update, :complete]
  before_filter :authorize_company, only: [:content, :update, :complete]
  before_filter :authorize_admin, only: [:update, :admin_content, :complete]


  def authorize_company
    unless current_user.right == "company" or current_user.right == "administrator" 
      redirect_to root_path, :notice => 'You are not authorized'
    end
  end

  def authorize_admin
    unless current_user.right == "administrator" 
      redirect_to root_path, :notice => 'You are not authorized'
    end
  end

  def approve
    @user = User.find_by_profile_name(params[:id])
    Event.where(id: params[:eventid]).update_all(published: 'published')
    @events = Event.all
    redirect_to user_path(current_user.profile_name) 
  end

  def disapprove
    @user = User.find_by_profile_name(params[:id])
    Event.where(id: params[:eventid]).update_all(published: 'waiting')
    @events = Event.all
    redirect_to user_path(current_user.profile_name) 
  end


  def complete
    User.where(:id => params[:complete_users]).update_all(right: "user")
    User.where(:id => params[:complete_companies]).update_all(right: "company")
    User.where(:id => params[:complete_admins]).update_all(right: "administrator")
    redirect_to manage_users_path
  end


  def show
    @user = User.find_by_profile_name(params[:id])
    if @user
      @subscriptions = Subscription.where(user_id: @user.id)
      @events = Event.all
      @places = Place.all.limit(2).order("RANDOM()")
      render action: :subscription
    else
      render file: 'public/404', status: 404, formats: [:html]
    end
  end

  def content
    @news = News.all
    @users = User.all
    @places = Place.all
    @events = Event.all
    @advertises = Advertise.all
    if user_signed_in?
    @users.each do |usr|
      if usr.id == current_user.id
        @user_name = usr.profile_name
        @user_id = usr.id
        @user_right = usr.right
      end
    end
    else
    render :file => "/app/views/places/index.html.erb",  :status => 'subscribed'
    end    
  end

  def update
    @user = User.all
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def user_params
      params.require(:user).permit(:id, :right)
    end
end
