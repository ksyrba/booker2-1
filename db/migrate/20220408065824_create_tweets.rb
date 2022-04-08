class CreateTweets < ActiveRecord::Migration[6.1]
  def change
    create_table :tweets do |t|
      t.integer :impressions_count, default: 0
      t.integer :user_id
      t.integer :book_id

      t.timestamps
    end
  end
end
