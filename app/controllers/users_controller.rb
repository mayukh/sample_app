class UsersController < ApplicationController


  def show
    @user = User.find(params[:id])
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
  
end
