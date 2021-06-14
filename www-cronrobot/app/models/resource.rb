
class Resource < ApplicationRecord
  serialize :params, JSON
  
  encrypts :params
end
