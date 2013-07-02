class Log < ActiveRecord::Base
  default_scope order('tm desc')
  self.abstract_class = true
  establish_connection(
    :adapter  => 'mysql2',
    :database => 'mbk',
    :username => 'philz',
    :password => 'asdyuh23')
  set_table_name 'log'
end
