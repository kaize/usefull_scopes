FactoryGirl.define do
  sequence :field_1 do |n|
    n
  end

  sequence :field_2 do |n|
    "string-#{n}"
  end

  sequence :field_3 do
    rand(3) % 2 == 0 ? true : false
  end
end
