require 'spec_helper'

describe User do
   # attr needs to be an instance variable
   before(:each) do
      @attr = {:name => "Example User", :email => "user@example.com",
               :password => "foobar", :password_confirmation => "foobar"}
   end

   it "should create a new instance given a valid attribute" do
      User.create!(@attr)
   end
   
    it "should require a name" do
       no_name_user = User.new(@attr.merge(:name => ""))
       no_name_user.should_not be_valid
    end
    
    it "should require a email" do
       no_email_user = User.new(@attr.merge(:email => ""))
       no_email_user.should_not be_valid
    end
    
    it "should reject names that are too long" do
      long_name = "m" * 51
      long_name_user = User.new(@attr.merge(:name => long_name))
      long_name_user.should_not be_valid
    end
    
    it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_crap@foo.org news+man@gmail.yahoo.com]
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
    end
    
    
    it "should reject invalid email addresses" do
      addresses = %w[user@foo,com THE_crap_at_foo.org newsman@gmail]
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should_not be_valid
      end
    end
    
    it "should reject duplicate email addresses" do 
      User.create!(@attr)
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end
    
    it "should reject email addresses that are different only in case" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end
    
    describe "passwords" do 
      it "should have a password attribute" do
        User.new(@attr).should respond_to(:password)
      end
      

      it "should have a password confirmation attribute" do
        User.new(@attr).should respond_to(:password_confirmation)
      end    
    end
    
    describe "password validations" do
      it "should require a password" do
        User.new(@attr.merge(:password => "", :password_confirmation => "")).
          should_not be_valid
      end
      
      it "should require a matching password confirmation" do
        User.new(@attr.merge(:password => "foo", :password_confirmation => "")).
          should_not be_valid
      end
      
      it "should reject short passwords" do
        short = "a" * 5
        hash = @attr.merge(:password => short, :password_confirmation => short)
        User.new(hash).should_not be_valid
      end
      
        it "should reject long passwords" do
          long = "a" * 41
          hash = @attr.merge(:password => long, :password_confirmation => long)
          User.new(hash).should_not be_valid
        end        
    end
    
    describe "password encryption" do
      before(:each) do
        @user = User.create!(@attr)
      end
      
      it "should have an encrypted password attribute" do
        @user.should respond_to(:encrypted_password)
      end
      
      it "should set the encrypted password attribute" do
            @user.encrypted_password.should_not be_blank
      end
      
      it "should respond to salt" do
          @user.should respond_to(:salt)
      end
    
      describe "has_password? method" do
     
       it "should return true if the passwords match" do
          @user.has_password?(@attr[:password]).should be_true
       end
     
       it "should return false if the passwords don't match" do
          @user.has_password?("invalid").should be_false
       end    
     end #describe has_password section
     
     describe "authenticate method" do
       
       it "should return nil on email/password mismatch" do
          User.authenticate(@attr[:email], "wrongpass").should be_nil
       end 
       
       it "should return nil for an email address with no user"  do
          User.authenticate("xxx@goo.com", @attr[:password]).should be_nil
       end
       
       it "should return user for the correct email/password combination" do
          User.authenticate(@attr[:email],@attr[:password]) == @user
       end
     end
   end #end describe passwords section
   
   describe "micropost association" do
    
      before(:each) do
        @user = User.create!(@attr)
        @mp1  = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
        @mp2  = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
      end
    
      it "should have a microposts attribute" do
        @user.should respond_to(:microposts)
      end
    
      it "shoud have the right microposts in the right order" do
        @user.microposts.should == [@mp2,@mp1]
      end 
    
      it "shoud destroy microposts when user is destroyed" do
        @user.destroy
          [@mp1,@mp2].each do |micropost|
            Micropost.find_by_id(micropost.id).should be_nil
        end
      end 
      describe "user feed" do
        it "should have a user feed" do
          @user.should respond_to(:feed)
        end

        it "should include the user's microposts" do
          @user.feed.should include(@mp1)
          @user.feed.should include(@mp2)
        end
        
        it "should not include a different user's microposts" do
          mp3  = Factory(:micropost, 
                         :user => Factory(:user, :email => Factory.next(:email)))
          @user.feed.should_not include(mp3)
        end
        
      end #user feed
      
      
    end  #describe micropost association 
    

   
    describe "admin attribute" do
     
     before(:each) do
      @user = User.create!(@attr)
     end
     
     it "should respond to admin" do
       @user.should respond_to(:admin)
     end
     
     it "should not be an admin by default" do
       @user.should_not be_admin
     end
     
     it "should be convertible to an admin" do
       @user.toggle!(:admin)
       @user.should be_admin
     end
   end
   
end
