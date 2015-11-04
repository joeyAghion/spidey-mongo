module Spidey::Strategies
  module Moped
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
      Spidey.logger.info "Queueing #{url.inspect[0..200]}..."
      url_collection.find(
        'spider' => self.class.name, 'url' => url
      ).upsert(
        '$set' => { 'handler' => handler, 'default_data' => default_data }
      )
    end

    def record(data)
      doc = data.merge('spider' => self.class.name)
      Spidey.logger.info "Recording #{doc.inspect[0..500]}..."
      if respond_to?(:result_key) && key = result_key(doc)
        result_collection.find('key' => key).upsert('$set' => doc)
      else
        result_collection.insert doc
      end
    end

    def each_url(&_block)
      while url = get_next_url
        break if url['last_crawled_at'] && url['last_crawled_at'] >= @crawl_started_at # crawled already in this batch
        url_collection.find('_id' => url['_id']).update('$set' => { last_crawled_at: Time.now })
        yield url['url'], url['handler'], url['default_data'].symbolize_keys
      end
    end

    def add_error(attrs)
      error = attrs.delete(:error)
      doc = attrs.merge(created_at: Time.now, error: error.class.name, message: error.message, spider: self.class.name)
      error_collection.insert doc
      Spidey.logger.error "Error on #{attrs[:url]}. #{error.class}: #{error.message}"
    end

    private

    def get_next_url
      return nil if @until && Time.now >= @until # exceeded time bound
      url_collection.find(spider: self.class.name).sort('last_crawled_at' => 1, '_id' => 1).first
    end
  end
end
