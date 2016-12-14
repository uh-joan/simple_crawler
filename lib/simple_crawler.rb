require 'simple_crawler/version'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'

module SimpleCrawler
  class Crawler
    def initialize(url)
      @url = url
      @doc = get_nokogiri url
      @output = []
    end

    def crawl (depth=1)
      unless @doc.nil?
        if depth > 0
          temp = []
          links = extract_links @doc
          links.each do |link|
            if is_a_partial_link_and_of_depth(link, depth)
              assets = get_assets( @url + link )
              unless assets.nil?
                temp << assets
              end
            end
          end
          @output.unshift(temp)
          crawl(depth - 1)
        else
          assets = get_assets( @url )
          unless assets.nil?
            @output.unshift( assets )
          end
        end
      end
      @output.flatten(1)
    end

    def get_assets (url)
      begin
        doc = get_nokogiri url
      rescue
        if url.start_with?('https')
          url = url.gsub('https', 'http')
          begin
            doc = get_nokogiri url
          rescue
            doc = nil
          end
        end

      end
      unless doc.nil?
        assets = extract_assets doc
        { url: url, assets: assets }
      end
    end

    def get_nokogiri (url)
      Nokogiri::HTML(open(url, 'Accept-Encoding' => 'plain', 'User-Agent' => 'chrome'))
    end

    def is_a_partial_link_and_of_depth (link, depth)
      begin
        # account only for partial links
        route_elements = link.split('/')
        (route_elements[0].empty? && route_elements.count == depth+1 ) ? true : false
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
      assets.flatten.compact.uniq.map { |asset|
        if asset.start_with?('/') && !asset.start_with?('//')
          # it a good partial link
          @url+asset
        elsif asset.start_with?('//')
          # assets might be a full url
          'https:'+asset
        else
          # something else
          asset
        end
      }
    end

  end
end
