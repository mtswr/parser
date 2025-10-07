class CreateEmailLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :email_logs do |t|
      t.string :filename
      t.string :source
      t.string :status
      t.text :extracted_data
      t.integer :customer_id
      t.text :error_message

      t.timestamps
    end
  end
end
