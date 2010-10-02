class CreateTimedTokens < ActiveRecord::Migration
  def self.up
    create_table :timed_tokens do |t|
      t.string :token
      t.integer :person_id
      t.datetime :expiration
      t.timestamps
    end
  end

  def self.down
    drop_table :timed_tokens
  end
end
