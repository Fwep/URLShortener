class TagTopic < ApplicationRecord
  validates :topic, uniqueness: true, presence: true 
end
