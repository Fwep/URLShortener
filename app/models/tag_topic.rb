class TagTopic < ApplicationRecord
  validates :topic, uniqueness: true, presence: true 

  has_many :taggings,
    primary_key: :id,
    foreign_key: :tag_id,
    class_name: :Tagging

  has_many :urls,
    through: :taggings,
    source: :url

  def popular_links
      links = self.urls.sort_by do |url|
        url.num_clicks
      end

      link_counts = []
      5.times do |i|
        link = links[i]
        link_counts.push([link.long_url, link.num_clicks]) unless link.nil?
      end
      link_counts
  end
end
