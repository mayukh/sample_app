require 'spec_helper'

describe UsersController do
  render_views
  
  describe "GET 'index'" do
    
    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
      end
    end #non signed-in
    
     describe "for signed-in users" do
      
       before(:each) do
        @user = test_sign_in(Factory(:user))
        Factory(:user, :email => "another@example.com")
        Factory(:user, :email => "another@example.net")
       end
        it "should be a success" do
          get :index
          response.should be_success
          #response.should redirect_to(signin_path)
        end
        
        it "should have the right title" do
          get :index
          response.should have_selector("title", 
                                         :content => "Users")
        end
        
        it "should have an element from each user" do
          get :index
          User.all.each do |user|
            response.should have_selector("li",:content => user.name)
          end
        end


      end #signed-in
    
  end #GET 
  
  
  describe "GET 'show'" do
    
   before(:each) do  
    @user = Factory(:user)
   end
   
   it "should be successful" do
     get :show, :id => @user  #Need a user id for testing the show method
     response.should be_success
   end
   
   it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
   end
   
   it "should have the right title" do
     get :show, :id => @user
     response.should have_selector("title",
     :content => "#{@user.name}")
     
   end 
   
   it "should have the user's name in h1 tags" do
     get :show, :id => @user
     response.should have_selector("h1",
       :content => "#{@user.name}")
   end
   
   it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector('h1>img', :class => "gravatar")
   end
   
   it "should have the right URL" do
     get :show, :id => @user
     response.should have_selector('td>a', :content => user_path(@user),
                                           :href    => user_path(@user))
   end 
  end #GET 'show'
  
  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
     it "should have the right title" do
        get :new
        response.should have_selector("title",
        :content => "Sign up")
     end  
  end #GET 'new'
  
  describe "POST 'create'" do
    
     describe "failure" do
       
       before(:each) do
         @attr = {:name => "", :email => "", :password => "",
                  :password_confirmation => ""}
       end
       
       it "should have the right title" do
         post :create, :user => @attr
         response.should have_selector('title', :content => "Sign up")
       end
       
       it "should render the 'new' page" do
         post :create, :user => @attr
         response.should render_template('new')
       end
       
       it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
       end

     end
     
     describe "success" do
       
       before(:each) do
         @attr = {:name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar"}
       end

        it "should ridirect to the 'show' page" do
          post :create, :user => @attr
          response.should redirect_to(user_path(assigns(:user)))
        end

        it "should create a user" do
         lambda do
           post :create, :user => @attr
         end.should change(User, :count).by(1 )
        end
         
        it "should have a welcome message" do
          post :create, :user => @attr
          flash[:success].should =~ /Welcome to the sample app/i
        end
            
        it "should sign the user in" do
          post :create, :user => @attr
          controller.should be_signed_in
        end     
     end #success
  end #POST create
  
  
   describe "GET 'edit'" do
    before(:each) do
     @user = test_sign_in(Factory(:user))
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector('title', :content => "Edit user")
    end
    
    it "should have a link to change the gravatar" do
      get :edit, :id => @user
      response.should have_selector('a', :href => 'http://gravatar.com/emails', 
                                         :content => "Change")
    end
  
   end #GET edit block
   ############
   describe "PUT 'update'" do
     
     before(:each) do
       @user = Factory(:user)
       test_sign_in(@user)
     end

      describe "failure" do

        before(:each) do
          @user 
          @attr = {:name => "", :email => "", :password => "",
                   :password_confirmation => ""}
        end

        it "should have the right title" do
          put :update, :id => @user , :user => @attr
          response.should have_selector('title', :content => "Edit user")
        end

        it "should render the 'edit' page" do
          put :update, :id => @user , :user => @attr
          response.should render_template('edit')
        end
        # 
        #  it "should not create a user" do
        #   lambda do
        #     post :create, :user => @attr
        #   end.should_not change(User, :count)
        #  end

      end #failure

      describe "success" do

        before(:each) do
          @attr = {:name => "New User", :email => "user@example.com",
                   :password => "foobar", :password_confirmation => "foobar"}
        end

         it "should change the user attributes" do
                        #current user, #new user info
           put :update, :id => @user , :user => @attr
           updated_user = assigns(:user) #binds @user form the controller is mapped to 
           @user.reload                  #reloads the just saved user from the database
           @user.name.should == updated_user.name
           @user.email.should == updated_user.email
           @user.encrypted_password.should == updated_user.encrypted_password
           #response.should redirect_to(user_path(assigns(:user)))
         end
         # 
         # it "should create a user" do
         #  lambda do
         #    post :create, :user => @attr
         #  end.should change(User, :count).by(1 )
         # end
         # 
         it "should have a flash message" do
           put :update, :user => @attr, :id => @user
           flash[:success].should =~ /updated/i
         end
         # 
         # it "should sign the user in" do
         #   post :create, :user => @attr
         #   controller.should be_signed_in
         # end     
      end #success
   end #POST create
   ############
   
   describe "authentication of edit/update actions" do
     
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "for non-signed in users" do
    
      it "should deny access to 'edit' without signin" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    
      it "should deny access to 'update' without signin" do
        put :update, :user => {}, :id => @user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    
    end #non signed-in users
   
    describe "for signed-in users" do
     
      before(:each) do
         wrong_user = Factory(:user, :email => "user@example.net")
         test_sign_in(wrong_user)
      end
   
      it "should require matching users for edit" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
    
      it "should require matching users for update" do
         put :update, :user => {}, :id => @user
         response.should redirect_to(root_path)
      end
     end #describe signed-in
   
  end #authentication
end
