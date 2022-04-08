class CreateTweets < ActiveRecord::Migration[6.1]
  def change
    create_table :tweets do |t|
      t.integer :impressions_count, default: 0

      t.timestamps
    end
  end
end
