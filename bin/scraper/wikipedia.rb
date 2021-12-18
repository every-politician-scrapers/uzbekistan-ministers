#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'table_unspanner'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class UnspanAllTables < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('table.wikitable').each do |table|
        unspanned_table = TableUnspanner::UnspannedTable.new(table)
        table.children = unspanned_table.nokogiri_node.children
      end
    end.to_s
  end
end

class MinistersList < Scraped::HTML
  decorator RemoveReferences
  # decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  field :ministers do
    member_entries.map { |ul| fragment(ul => Officeholder).to_h }
                  .reject { |row| row[:name].to_s.empty? }
  end

  private

  # TODO: add the Chairmen of State Committees back in
  def member_entries
    noko.xpath('//table[.//th[contains(.,"Должность")]][position() < 3]//tr[td]')
  end
end

class Officeholder < Scraped::HTML
  field :wdid do
    tds[1].css('a/@wikidata').first if tds[1]
  end

  field :name do
    tds[1].text.tidy if tds[1]
  end

  private

  def tds
    noko.css('td')
  end
end

url = 'https://ru.wikipedia.org/wiki/%D0%9A%D0%B0%D0%B1%D0%B8%D0%BD%D0%B5%D1%82_%D0%BC%D0%B8%D0%BD%D0%B8%D1%81%D1%82%D1%80%D0%BE%D0%B2_%D0%A3%D0%B7%D0%B1%D0%B5%D0%BA%D0%B8%D1%81%D1%82%D0%B0%D0%BD%D0%B0'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).ministers

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
