class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, presence: true, uniqueness: true
  validates :user_id, presence: true, uniqueness: false

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  def self.random_code
    code = SecureRandom.urlsafe_base64

    until !ShortenedUrl.exists?(code)
      code = SecureRandom.urlsafe_base64
    end
    
    code
  end

  def self.create_short_url(user, long_url)
    ShortenedUrl.create!(user_id: user.id, long_url: long_url, short_url: self.random_code)
  end
end
