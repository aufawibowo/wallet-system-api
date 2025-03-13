class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      # If either is System, it references the system’s wallet
      t.references :source_wallet, null: false, foreign_key: { to_table: :wallets }
      t.references :target_wallet, null: false, foreign_key: { to_table: :wallets }

      t.decimal :amount, precision: 15, scale: 2, null: false

      # Optionally: a string or enum for "credit/debit/transfer"
      # t.string :transaction_type, null: false, default: "transfer"

      t.timestamps
    end
  end
end
