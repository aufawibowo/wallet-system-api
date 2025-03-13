class CreateStockPriceLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_price_logs do |t|
      t.references :user, null: true
      t.string :symbol, null: false
      t.decimal :price, precision: 15, scale: 4, null: false
      t.timestamps
    end
  end
end
