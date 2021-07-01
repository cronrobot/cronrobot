class CreateAuthTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :auth_tokens do |t|
      t.string :client_id
      t.string :client_secret

      t.timestamps
    end
  end
end
