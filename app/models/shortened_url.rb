class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, presence: true, uniqueness: true
  validates :user_id, presence: true, uniqueness: false
  validate :no_spamming, :nonpremium_max

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
    
    def self.prune(n)
      ShortenedUrl
        .joins(:submitter)
        .joins("LEFT JOIN visits ON visits.url_id = shortened_urls.id")
        .where(<<-SQL, n.minutes.ago, n.minutes.ago, false)
          shortened_urls.id IN (
            SELECT
              shortened_urls.id
            FROM
              shortened_urls
            JOIN
              visits ON visits.url_id = shortened_urls.id
            GROUP BY
              shortened_urls.id
            HAVING
              MAX(visits.created_at) < ?
          ) OR (visits.id IS NULL AND shortened_urls.created_at > ? )
            AND
            users.premium = ?
        SQL
        .destroy_all
    end
    
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
    self.visits.select(:user_id).where(" ? > created_at", 10.minutes.ago).distinct.count() # Violating Law of Demeter, I know
  end


  private
  def no_spamming
    user = User.find(self.user_id)
    fifth_to_last = user.submitted_urls[5]
    if fifth_to_last && fifth_to_last.created_at < 1.minutes.ago
      errors[:user] << "Can't submit more than 5 URLs in a single minute!"
    end
  end

  def nonpremium_max
    user = User.find(self.user_id)
    if user.submitted_urls[5] && !user.premium
      errors[:user] << "Non-premium users limited to 5 submitted URLs"
    end
  end
end