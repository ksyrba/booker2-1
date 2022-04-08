class Tweet < ApplicationRecord
  is_impressionable counter_cache: true
end
