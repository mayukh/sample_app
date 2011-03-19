class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit,:update,:index, :destroy]
  before_filter :correct_user, :only => [:edit,:update]
  before_filter :admin_user,   :only => [:destroy]
   
  def index
    @users = User.paginate(:page => params[:page])  #using this for pagination instead of each
    @title = "Users"
  end
  
  def show
    @user = User.find(params[:id])
#   @microposts = @user.microposts
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end
  
  def new

    @user  = User.new
    @title = "Sign up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user  #After signing up we should create a new session
      #Handle a successful save
      #send it to the show page users/1  
      redirect_to @user , :flash => {:success => "Welcome to the Sample App!"} 
    else 
      @title = "Sign up"
      render 'new'
    end
  end
  
  def edit 
    @title = "Edit user"
  end
  
  def update
    if @user.update_attributes(params[:user])
          redirect_to @user, :flash => {:success => "Profile updated."}
    else
      @title = "Edit user"
      render 'edit'
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if current_user?(@user)
      redirect_to users_path, :flash => {:error => "Cannot delete self."}
    else
      @user.destroy
      redirect_to users_path, :flash => {:success => "User Destroyed."}
    end
  end
  
  private 

  
  def correct_user
    @user = User.find(params[:id])  #pull out the user from the resource we are trying to access
    redirect_to(root_path) unless current_user?(@user)
  end
  
  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  
end
