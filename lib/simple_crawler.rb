require 'simple_crawler/version'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'

module SimpleCrawler
  class Crawler
    def initialize (url)
      @url    = url
      @doc    = Nokogiri::HTML(open(@url, "Accept-Encoding" => "plain", "User-Agent" => "chrome"))
      @output = []
    end

    def crawl (depth=1)
      unless @doc.nil?
        if depth > 0
          temp = []
          links = extract_links @doc
          links.each do |link|
            if is_a_partial_link_and_of_depth(link, depth)
              temp << save_assets( @url + link )
            end
          end
          @output.unshift(temp)
          crawl(depth - 1)
        else
          @output.unshift( save_assets( @url ) )
        end
      end
      @output.flatten(1)
    end

    def save_assets (url)
      begin
        doc = Nokogiri::HTML(open(url, "Accept-Encoding" => "plain", "User-Agent" => "chrome"))
      rescue
        doc = nil
      end
      unless doc.nil?
        assets = extract_assets doc
        { url: url, assets: assets }
      end
    end

    def is_a_partial_link_and_of_depth (link, depth)
      begin
        # account only for partial links
        route_elements = link.split('/')
        (route_elements[0].empty? && route_elements.count == depth+1) ? true : false
      rescue
        false
      end
    end

    def extract_links (doc)
      # lets consider only the link within a tag
      links = doc.css('a').map { |link| link['href'] }
      links.compact.uniq
    end

    def extract_assets (doc)
      # lets consider assets in link, script and image elements
      assets = []
      assets << doc.xpath('//link[not(@rel="alternate")][not(@rel="canonical")][not(@rel="publisher")]').map{ |link| link['href'] }
      assets << doc.xpath('//script').map{ |link| link['src'] }
      assets << doc.xpath('//img').map { |link| link['src'] }
      # get rid of nils, duplicates and attach the domain to only the assets with partial links
      assets.flatten.compact.uniq.map { |asset| asset.start_with?('/') && !asset.start_with?('//')? @url+asset : asset }
    end
  end
end
