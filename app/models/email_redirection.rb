class EmailRedirection < ActiveRecord::Base
  validates :user_name, :presence => true, :uniqueness => true
  validates :destination, :presence => true
end
