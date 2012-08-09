module Spidey::Strategies
  module Mongo
    attr_accessor :url_collection, :result_collection, :error_collection
  
    def initialize(attrs = {})
      self.url_collection = attrs.delete(:url_collection)
      self.result_collection = attrs.delete(:result_collection)
      self.error_collection = attrs.delete(:error_collection)
      super attrs
    end
  
    def crawl(options = {})
      @crawl_started_at = Time.now
      @until = Time.now + options[:crawl_for] if options[:crawl_for]
      super options
    end
  
    def handle(url, handler, default_data = {})
      $stderr.puts "Queueing #{url.inspect.truncate(500)}" if verbose
      url_collection.update(
        {'spider' => self.class.name, 'url' => url},
        {'$set' => {'handler' => handler, 'default_data' => default_data}},
        upsert: true
      )
    end
  
    def record(data)
      doc = data.merge('spider' => self.class.name)
      $stderr.puts "Recording #{doc.inspect.truncate(500)}" if verbose
      if respond_to?(:result_key) && key = result_key(doc)
        result_collection.update({'key' => key}, {'$set' => doc}, upsert: true)
      else
        result_collection.insert doc
      end
    end
  
    def each_url(&block)
      while url = get_next_url
        break if url['last_crawled_at'] && url['last_crawled_at'] >= @crawl_started_at  # crawled already in this batch
        url_collection.update({'_id' => url['_id']}, '$set' => {last_crawled_at: Time.now})
        yield url['url'], url['handler'], url['default_data'].symbolize_keys
      end
    end
  
    def add_error(attrs)
      error = attrs.delete(:error)
      doc = attrs.merge(created_at: Time.now, error: error.class.name, message: error.message, spider: self.class.name)
      error_collection.insert doc
      $stderr.puts "Error on #{attrs[:url]}. #{error.class}: #{error.message}" if verbose
    end
  
  private

    def get_next_url
      return nil if (@until && Time.now >= @until)  # exceeded time bound
      url_collection.find_one({spider: self.class.name}, {
        sort: [[:last_crawled_at, ::Mongo::ASCENDING], [:_id, ::Mongo::ASCENDING]]
      })
    end
  
  end
end
