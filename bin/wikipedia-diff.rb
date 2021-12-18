#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'

# Only compare IDs, not names, as those differ between WP/WD
class Comparison < EveryPoliticianScraper::Comparison
end

diff = Comparison.new('data/wikidata-wp.csv', 'data/wikipedia.csv').diff
puts diff.sort_by { |r| [r.first, r[1].to_s] }.reverse.map(&:to_csv)
