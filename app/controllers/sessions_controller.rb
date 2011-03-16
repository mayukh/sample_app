class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
  end 
  
  def destroy
    @title = "Sign out"
  end

end
