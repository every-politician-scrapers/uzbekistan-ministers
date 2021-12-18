#!/bin/bash

bundle exec ruby bin/scraper/official.rb | ifne tee data/official.csv
wd sparql -f csv bin/scraper/wikidata.js | sed -e 's/T00:00:00Z//g' | qsv dedup -s psid | ifne tee data/wikidata.csv
bundle exec ruby bin/diff.rb | tee data/diff.csv
