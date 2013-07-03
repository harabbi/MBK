class StagedVolusion < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(
    :adapter  => 'mysql2',
    :database => 'volusion',
    :username => 'philz',
    :password => 'asdyuh23')
  set_table_name 'Products_Joined'
end
