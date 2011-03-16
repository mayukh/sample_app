class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    # params hash contains session info
    user = User.authenticate(params[:session][:email],
                             params[:session][:password]) 
    #if failed to sign in                                     
    if user.nil?                 
      flash.now[:error] = "Invalid email/password combinaton"
      @title = "Sign in"
      render 'new' 
    else #Handle successful signin
      
    end
    
    
  end 
  
  def destroy
    @title = "Sign out"
  end

end
