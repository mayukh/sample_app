require 'spec_helper'

describe SessionsController do
  render_views
  
  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector("title",
      :content => "Sign in")
    end
    
  end #end get new
  
  describe "POST 'create'" do
    
     describe "failure" do
       
       before(:each) do
         @attr = {:email => "", :password => ""}
       end
       
       it "should re-render the new page" do
         post :create, :session => @attr
         response.should render_template('new')
       end
       
       it "should have the right title" do
         post :create, :session => @attr
         response.should have_selector("title", :content => "Sign in")
       end
       
       it "should have an error message" do
          post :create, :session => @attr
          flash.now[:error].should =~ /Invalid/i
          response.should have_selector("title", :content => "Sign in")
        end
       
      end #failure
      
      describe "success" do
        before(:each) do
          @user = Factory(:user)
          @attr = {:email => @user.email, :password => @user.password }
        end
        
        it "should sign the user in " do
          post :create, :session => @attr
          # current_user attached to the sessions controller should 
          #== user posted to the session resource?
          controller.current_user.should == @user
          #Implies we need to have a signed_in? method in controller
          controller.should be_signed_in
        end
        
        it "should redirect to the user show page" do
          post :create, :session => @attr
          response.should redirect_to(user_path(@user))
        end
      end #success
      
    end #POST

end
