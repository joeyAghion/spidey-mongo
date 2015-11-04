require 'spec_helper'
require 'mongo'

describe Spidey::Strategies::Mongo do
  class TestMongoSpider < Spidey::AbstractSpider
    include Spidey::Strategies::Mongo
    handle 'http://www.cnn.com', :process_home

    def result_key(data)
      data[:detail_url]
    end
  end

  before(:each) do
    @db = Mongo::Connection.new['spidey-mongo-test']
    @spider = TestMongoSpider.new(
      url_collection: @db['urls'],
      result_collection: @db['results'],
      error_collection: @db['errors'])
  end

  after(:each) do
    %w( urls results errors ).each { |col| @db[col].drop }
  end

  it 'should add initial URLs to collection' do
    doc = @db['urls'].find_one(url: 'http://www.cnn.com')
    expect(doc['handler']).to eq(:process_home)
    expect(doc['spider']).to eq('TestMongoSpider')
  end

  it 'should not add duplicate URLs' do
    @spider.send :handle, 'http://www.cnn.com', :process_home
    expect(@db['urls'].find(url: 'http://www.cnn.com').count).to eq(1)
  end

  it 'should add results' do
    @spider.record detail_url: 'http://www.cnn.com', foo: 'bar'
    expect(@db['results'].count).to eq(1)
    doc = @db['results'].find_one
    expect(doc['detail_url']).to eq('http://www.cnn.com')
    expect(doc['foo']).to eq('bar')
    expect(doc['spider']).to eq('TestMongoSpider')
  end

  it 'should update existing result' do
    @db['results'].insert key: 'http://foo.bar', detail_url: 'http://foo.bar'
    @spider.record detail_url: 'http://foo.bar', foo: 'bar'
    expect(@db['results'].count).to eq(1)
  end

  it 'should add error' do
    @spider.add_error error: Exception.new('WTF'), url: 'http://www.cnn.com', handler: :blah
    doc = @db['errors'].find_one
    expect(doc['error']).to eq('Exception')
    expect(doc['url']).to eq('http://www.cnn.com')
    expect(doc['handler']).to eq(:blah)
    expect(doc['message']).to eq('WTF')
    expect(doc['spider']).to eq('TestMongoSpider')
  end
end
