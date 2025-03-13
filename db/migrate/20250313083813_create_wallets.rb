class CreateWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true

      # Store the user’s total balance at a point in time
      t.decimal :balance, precision: 15, scale: 2, default: 0, null: false

      # Possibly track why this snapshot changed (optional)
      t.string :reason

      t.timestamps
    end
  end
end
