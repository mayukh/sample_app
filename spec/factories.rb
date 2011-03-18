Factory.define :user do |user|
  user.name                     "Mayukh Mukherjee"
  user.email                    "mayukhm@gmail.com"
  user.password                 "foobar"
  user.password_confirmation    "foobar"
end

Factory.sequence :email do |n|
  "person-#{n}@example.org"
end

Factory.define :micropost do |micropost|
  micropost.content      "Lorem ipsum Foo"
  micropost.association  :user
end