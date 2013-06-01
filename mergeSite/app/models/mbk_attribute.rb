class MbkAttribute < ActiveRecord::Base
  default_scope :order => 'name'
  attr_accessible :name

  validates :name, :uniqueness => :true
end
