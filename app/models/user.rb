# == Schema Information
# Schema version: 20110316014533
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#

class User < ActiveRecord::Base
  attr_accessor   :password
  attr_accessible :name, :email, :password, :password_confirmation
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  #local variable
  
  
  validates :name,  :presence  => true,
                    :length     => { :maximum => 50 }
                    
  validates :email, :presence   => true,
                    :format     => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }
                    
  validates :password, :presence => true,
                       :confirmation => true, 
                       :length => { :within => 6..40 }
  
  before_save :encrypt_password  #register callback
  
  def has_password?(submitted_password)
    #passwd in the db should match encrypted version of submitted password
    encrypted_password == encrypt(submitted_password)
  end
  
  #returns nil if password doesnt match or email doesn't exist
  def User.authenticate(email,submitted_password)
     user = find_by_email(email)
     return nil  if user.nil?   #couldn't find this user
     
     return user if user.has_password?(submitted_password) #Match return the user
     
     #Doesn't match returns nil implicitly
     
  end
  
  private 
      def encrypt_password
        self.salt = make_salt if new_record?
        #encrypted_password is a db attribute that is not accessible directly
        self.encrypted_password = encrypt(password) #access self.password
      end
      
      def encrypt(string)
        secure_hash("#{salt}--#{string}") #string #Not final implementation!
      end
      
      def secure_hash(string)
        Digest::SHA2.hexdigest(string)
      end
      
      def make_salt
        secure_hash("#{Time.now.utc}--#{password}")
      end
end
