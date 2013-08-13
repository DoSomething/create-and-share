# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :school do
    gsid 1
    title "MyString"
    state "MyString"
    city "MyString"
    zip "MyString"
  end
end
