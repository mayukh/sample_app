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
        
         30.times do 
           Factory(:user, :email => Factory.next(:email))
         end
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
          User.paginate(:page => 1).each do |user|
            response.should have_selector("li",:content => user.name)
          end
        end
        
        it "should paginate users" do
          get :index
          response.should have_selector('div.pagination')
          response.should have_selector('span.disabled', :content => "Previous")
          response.should have_selector('a', :href => "/users?page=2",
                                             :content => "2")
        end
        
        it "should have delete links for admin users" do
           @user.toggle!(:admin)
           other_user = User.all.second
           get :index
           response.should have_selector('a', :href => user_path(other_user),
                                              :content => "delete")
         end
                                              
         it "should not have delete links for non-admin users" do
             other_user = User.all.second
             get :index
             response.should_not have_selector('a', :href => user_path(other_user),
                                                    :content => "delete")
        
        end
      end #signed-in    
  end #GET index
  
  
  describe "GET 'show'" do
    
   before(:each) do  
     @user = Factory(:user)

     # @user = test_sign_in(Factory(:user))
     # Factory(:user, :email => "another@example.com")
     # Factory(:user, :email => "another@example.net")
     #    
     # 51.times do 
     #   Factory(:user, :email => Factory.next(:email))
     # end

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
   
   it "should show the user's microposts" do
     mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
     mp2 = Factory(:micropost, :user => @user, :content => "Quack Quack")
     get :show, :id => @user
     response.should have_selector('span.content', :content => mp1.content)
     response.should have_selector('span.content', :content => mp2.content)
     
   end
   
    it "should paginate microposts" do
       31.times { Factory(:micropost, :user => @user, :content => "Foo bar") }
       get :show, :id => @user
       response.should have_selector('div.pagination')
       # response.should have_selector('span.disabled', :content => "Previous")
       # response.should have_selector('a', :href => "/users?page=2",
       #                                    :content => "2")
    
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
  
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-signed in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end #describe non-signed in
    
    describe "as non-admin user" do
      it "should protect the action" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end #non-admin
    
      describe "as admin user" do
        
        before(:each)do
          @admin = Factory(:user, :email => "admin@example.com", :admin => true)
          test_sign_in(@admin)
        end
        
        it " should destroy the user" do
          lambda do
            delete :destroy, :id => @user
          end.should change(User, :count).by(-1)
        end
    
        it "should redirect to the users page" do
          delete :destroy, :id => @user
          response.should redirect_to(users_path)
        end
        
        it "should not be able to destroy itself" do
        lambda do
          delete :destroy, :id => @admin
        end.should_not change(User, :count)
        end
     end #admin
    
    
  end# describe "DELETE 'destroy'"
end
