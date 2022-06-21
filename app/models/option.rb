# frozen_string_literal: true

class Option < ApplicationRecord
  enum agents: ['Linux Firefox', 'Linux Mozilla', 'Mac Mozilla', 'Windows IE 6', 'Windows IE 9', 'Windows Mozilla',
                'iPad']
end
