class CreateWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :wallets do |t|
      # Polymorphic association if multiple entity types share the same Wallet model
      t.string  :owner_type, null: false
      t.bigint  :owner_id,   null: false

      t.decimal :balance, precision: 15, scale: 2, default: 0, null: false

      # Optional: an index to speed up finding the wallet for a given entity
      t.index [:owner_type, :owner_id], unique: true
      t.timestamps
    end
  end
end
