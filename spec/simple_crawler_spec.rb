require 'spec_helper'
require 'nokogiri'
require 'open-uri'

describe SimpleCrawler do

  let (:url) { 'https://gocardless.com' }
  let (:crawler) { SimpleCrawler::Crawler.new(url) }


  # page = <<-HTML
  # HTML

  context '#extract' do
    let (:doc) { Nokogiri::HTML(open(url, "Accept-Encoding" => "plain", "User-Agent" => "chrome")) }
    it 'should extract the links from a url' do
      expect(crawler.extract_links(doc).count).to eq(47)
    end

    it 'should extract the assets from a url' do
      expect(crawler.extract_assets(doc).count).to eq(16)
    end
  end

  context '#crawl with different depths' do

    it 'crawls the url with depth 0' do
      expect(crawler.crawl(0).count).to eq(1)
    end

    it 'crawls the url with depth 1' do
      expect(crawler.crawl(1).count).to eq(37)
      end


    it 'crawls the url with depth 2' do
      expect(crawler.crawl(2).count).to eq(43)
    end


    it 'crawls the url with depth 3' do
      expect(crawler.crawl(3).count).to eq(44)
    end
  end

end
