class Tagging < ApplicationRecord
  validates :tag_id, :url_id, presence: true
  validate :combo_of_url_and_tag

  belongs_to :url,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: :ShortenedUrl

  belongs_to :tag_topic,
    primary_key: :id,
    foreign_key: :tag_id,
    class_name: :TagTopic

  private
  def combo_of_url_and_tag
    if Tagging.find_by(tag_id: self.tag_id, url_id: self.url_id)
      errors[:tagging] << "URL already tagged with given tag topic!"
    end
  end
end
