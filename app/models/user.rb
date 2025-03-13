class User < ApplicationRecord
  has_secure_password  # if using built-in Rails password handling
  has_one :wallet, as: :owner, dependent: :destroy
end
