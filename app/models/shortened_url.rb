class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, presence: true, uniqueness: true
  validates :user_id, presence: true, uniqueness: false

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  has_many :visits,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: :Visit

  has_many :visitors,
    Proc.new { distinct }, 
    through: :visits,
    source: :visitor

  has_many :taggings,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: :Tagging

  has_many :tag_topics,
    through: :taggings,
    source: :tag_topic

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

  def num_clicks
    self.visits.select(:user_id).count()
  end

  def num_uniques
    self.visitors.count()
  end

  def num_recent_uniques
    self.visits.select(:user_id).where(" ? > created_at", 10.minutes.ago).distinct.count()
  end
end
