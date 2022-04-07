class Message < ApplicationRecord
  belongs_to :room
  belongs_to :user
  
  validates :message, presence: true, length: { maximum: 140 }
end
