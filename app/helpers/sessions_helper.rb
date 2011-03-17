module SessionsHelper
#by default these helpers are available in the views
#to have these in the controller access them in ApplicationController


  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt] 
    current_user = user   #Sets @current_user = user. current_user is a method
  end
  
  #assign attribute ; setter method
  def current_user=(user)
    @current_user = user
  end
  
  #getter method to access instance variable @current_user
  def current_user  
    #Not just @current_user
    #@current_user is an instance variable
    #and it is being reset between requests
    #so this is the way to persist
    #user_from_.... is a method that helps persist 
    @current_user ||=  user_from_remember_token
  end

  def signed_in?
    !current_user.nil?
  end
  
  def sign_out
    cookies.delete(:remember_token)
    current_user = nil
  end
  
  
  def deny_access
    redirect_to signin_path, :notice => "Please Sign in."
  end
  
  private 
  def user_from_remember_token
     User.authenticate_with_salt(*remember_token)
  end
  
  def remember_token
    cookies.signed[:remember_token] || [nil,nil]
  end
end
