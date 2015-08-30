FactoryGirl.define do
  factory :user do
    name "Daisuke Nagayama"
    email "jaga@yahoo.co.jp"
    password "foobar"
    password_confirmation "foobar"
  end
end