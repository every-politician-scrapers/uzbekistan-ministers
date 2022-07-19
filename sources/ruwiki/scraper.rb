#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Members
    decorator RemoveReferences
    decorator UnspanAllTables
    decorator WikidataIdsDecorator::Links

    def member_items
      super.reject(&:empty?)
    end

    # TODO: add the Chairmen of State Committees back in
    def member_container
      noko.css('table li').remove
      noko.xpath('//table[.//th[contains(.,"Должность")]][position() < 3]//tr[td]')
    end
  end

  class Member
    field :id do
      name_node.css('a/@wikidata').first
    end

    field :name do
      name_node.text.tidy
    end

    field :positionID do
    end

    field :position do
      tds[0].text.tidy.split(/ [-—] (?=министр)/).map(&:tidy)
    end

    field :startDate do
    end

    field :endDate do
    end

    def empty?
      tds[0].text == tds[1].text
    end

    private

    def tds
      noko.css('td')
    end

    def name_node
      tds[1]
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url).csv
