class StagedMagento < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(
    :adapter  => 'mysql2',
    :database => 'magento',
    :username => 'philz',
    :password => 'asdyuh23')
  set_table_name 'm_products'
end
