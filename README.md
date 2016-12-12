#Simple Web Crawler

Given a starting URL, it visits every reachable page under that domain, up to a given depth.

For each page, it determines the URLs of every static asset (images, javascript, stylesheets) on that page.

The crawler outputs to STDOUT in JSON format listing the URLs of every static asset, grouped by page.

```
For example:
[
  {
    "url": "http://www.example.org",
    "assets": [
      "http://www.example.org/image.jpg",
      "http://www.example.org/script.js"
    ]
  },
  {
    "url": "http://www.example.org/about",
    "assets": [
      "http://www.example.org/company_photo.jpg",
      "http://www.example.org/script.js"
    ]
  },
  ..
]
```

## Depth

The depth determines the links to reach from the main domain, for example:

```
- Depth 0
  http://www.example.org

- Depth 1
  http://www.example.org/about
  http://www.example.org/contact
  http://www.example.org/faq
  http://www.example.org/blog

- Depth 2
  http://www.example.org/blog/news
  http://www.example.org/faq/english
  http://www.example.org/faq/french
```

## Installation

```ruby
gem 'simple_crawler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_crawler

## Usage

Create a crawler and crawl with a given depth:

    crawler = SimpleCrawler::Crawler.new(url)
    crawler.crawl(depth)

## Development

To install this gem onto your local machine, run `bundle exec rake install`.

Run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/uh-joan/simple_crawler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

