Spidey-Mongo
============

[![Build Status](https://travis-ci.org/joeyAghion/spidey-mongo.svg?branch=master)](https://travis-ci.org/joeyAghion/spidey-mongo)

This gem implements a [MongoDB](http://www.mongodb.org/) back-end for [Spidey](https://github.com/joeyAghion/spidey), a very simple framework for crawling and scraping web sites.

See [Spidey](https://githubcom/joeyAghion/spidey)'s documentation for a basic example spider class.

The default implementation stores the queue of URLs being crawled, any generated results, and errors as attributes on the spider instance (i.e., in memory). By including this gem's module, spider implementations can store them in a MongoDB database instead.

Usage
-----

### Install the gem

    gem install spidey-mongo


### `mongo` versus `moped`

Spidey-Mongo provides two strategies:

* `Spidey::Strategies::Mongo`: Compatible with Mongo Ruby Driver, [`mongo`](https://github.com/mongodb/mongo-ruby-driver), 1.x
* `Spidey::Strategies::Moped`: Compatible with the [`moped`](https://github.com/mongoid/moped) 2.x, e.g., for use with Mongoid 3.x

You can include either strategy in your classes, as appropriate. All the examples in this README assume `Spidey::Strategies::Mongo`.

### Example spider class

    class EbaySpider < Spidey::AbstractSpider
      include Spidey::Strategies::Mongo

      handle "http://www.ebay.com", :process_home

      def process_home(page, default_data = {})
        # ...
      end
    end

### Invocation

The spider's constructor accepts new parameters for each of the MongoDB collections to employ: `url_collection`, `result_collection`, and `error_collection`.

    db = Mongo::Connection.new['example']

    spider = EbaySpider.new(
      url_collection: db['urls'],
      result_collection: db['results'],
      error_collection: db['errors'])

With persistent storage of the URL-crawling queue, it's now possible to stop crawling and resume at a later point. The `crawl` method accepts a new optional `crawl_for` parameter specifying the number of seconds after which to stop.

    spider.crawl crawl_for: 600  # seconds, or more conveniently (w/ActiveSupport): 10.minutes

(The base implementation's `max_urls` parameter is also useful for this purpose.)

### Recording Results

By default, invocations of `record(data)` by the spider simply insert new documents into the result collection. If corresponding results may already exist in the collection and should instead be updated, define a `result_key` method that returns a key by which to find the corresponding document. The method is called with a hash of the data being recorded:

    class EbaySpider < Spidey::AbstractSpider
      include Spidey::Strategies::Mongo

      def result_key(data)
        data[:detail_url]
      end

      # ...
    end

This performs an `upsert` instead of the usual `insert` (i.e., an update if a result document matching the key already exists, or insert otherwise).

Testing
-------

    bundle exec rspec

Contributors
------------

[Joey Aghion](https://github.com/joeyAghion), [Frank Macreery](https://github.com/fancyremarker)

To Do
-----
* Extract behaviors shared by `Mongo` and `Moped` strategies.

Copyright
---------
Copyright (c) 2012, 2013 Joey Aghion, Artsy Inc. See [LICENSE.txt](LICENSE.txt) for further details.
