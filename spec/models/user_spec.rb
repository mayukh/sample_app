require 'spec_helper'

describe User do
   # attr needs to be an instance variable
   before(:each) do
      @attr = {:name => "Example User", :email => "user@example.com"}
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
    
end
