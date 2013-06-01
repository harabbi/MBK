class CustomerSearch < ActiveRecord::Base
  def self.contains_searches
    [
      "firstname",
      "lastname",
      "billingaddress1",
      "billingaddress2",
      "city",
      "state",
      "postalcode",
      "country",
      "phonenumber",
      "faxnumber",
      "emailaddress"
    ]
  end
end
