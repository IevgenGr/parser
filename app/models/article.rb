class Article < ApplicationRecord
  belongs_to :source
  validates :headline, uniqueness: true
end
