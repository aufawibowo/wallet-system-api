class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true

      # Double-entry principle:
      t.decimal :debit,  precision: 15, scale: 2, default: 0, null: false
      t.decimal :credit, precision: 15, scale: 2, default: 0, null: false

      # Optional: to group or describe the transaction
      t.string :reference
      t.string :description

      t.timestamps
    end
  end
end
