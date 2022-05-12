class Article < ApplicationRecord
  belongs_to :source
  validates :headline, uniqueness: true
  scope :date_uniq, -> {group('created_at::date').count.keys.sort}
end
