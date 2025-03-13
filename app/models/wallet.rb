class Wallet < ApplicationRecord
  belongs_to :owner, polymorphic: true
end
