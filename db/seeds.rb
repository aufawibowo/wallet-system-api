# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

require 'digest'

# Simple helper for "naive" password hashing
def naive_hash_password(password)
  Digest::SHA256.hexdigest("my_salt_#{password}_secret")
end

# Clear existing data
Transaction.destroy_all
Wallet.destroy_all
User.destroy_all

# 1) Create two users: Alice & Bob
alice = User.create!(
  email:           "alice@example.com",
  password_digest: naive_hash_password("password123")
)

bob = User.create!(
  email:           "bob@example.com",
  password_digest: naive_hash_password("password123")
)

# 2) Give Alice an initial deposit of 100
Transaction.create!(
  user_id:    alice.id,
  debit:      0,
  credit:     100,
  description: "Initial deposit for Alice"
)
# Snapshot of Alice's new balance
Wallet.create!(
  user_id: alice.id,
  balance: 100,
  reason:  "Initial deposit"
)

# 3) Give Bob an initial deposit of 50
Transaction.create!(
  user_id:    bob.id,
  debit:      0,
  credit:     50,
  description: "Initial deposit for Bob"
)
# Snapshot of Bob's new balance
Wallet.create!(
  user_id: bob.id,
  balance: 50,
  reason:  "Initial deposit"
)

# 4) Alice transfers 30 to Bob (double-entry in transactions)
Transaction.create!(
  user_id:    alice.id,
  debit:      30,
  credit:     0,
  description: "Transfer to Bob"
)
Transaction.create!(
  user_id:    bob.id,
  debit:      0,
  credit:     30,
  description: "Received from Alice"
)

# Update snapshots for both
Wallet.create!(
  user_id: alice.id,
  balance: 70,  # 100 - 30
  reason:  "After transferring 30 to Bob"
)
Wallet.create!(
  user_id: bob.id,
  balance: 80,  # 50 + 30
  reason:  "After receiving 30 from Alice"
)

puts "Seeding complete!"
puts "Created #{User.count} users, #{Transaction.count} transactions, #{Wallet.count} wallet snapshots."
