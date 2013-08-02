require 'spec_helper'
require 'moped'

describe Spidey::Strategies::Moped do
  class TestMopedSpider < Spidey::AbstractSpider
    include Spidey::Strategies::Moped
    handle "http://www.cnn.com", :process_home

    def result_key(data)
      data[:detail_url]
    end
  end

  before(:each) do
    @db = Moped::Session.new(['127.0.0.1:27017'])
    @db.use 'spidey-mongo-test'
    @spider = TestMopedSpider.new(
      url_collection: @db['urls'],
      result_collection: @db['results'],
      error_collection: @db['errors'])
  end

  after(:each) do
    %w{ urls results errors }.each{ |col| @db[col].drop }
  end

  it "should add initial URLs to collection" do
    doc = @db['urls'].find(url: "http://www.cnn.com").first
    doc['handler'].should == :process_home
    doc['spider'].should == 'TestMopedSpider'
  end

  it "should not add duplicate URLs" do
    @spider.send :handle, "http://www.cnn.com", :process_home
    @db['urls'].find(url: "http://www.cnn.com").count.should == 1
  end

  it "should add results" do
    @spider.record detail_url: 'http://www.cnn.com', foo: 'bar'
    @db['results'].find.count.should == 1
    doc = @db['results'].find.first
    doc['detail_url'].should == 'http://www.cnn.com'
    doc['foo'].should == 'bar'
    doc['spider'].should == 'TestMopedSpider'
  end

  it "should update existing result" do
    @db['results'].insert key: 'http://foo.bar', detail_url: 'http://foo.bar'
    @spider.record detail_url: 'http://foo.bar', foo: 'bar'
    @db['results'].find.count.should == 1
  end

  it "should add error" do
    @spider.add_error error: Exception.new("WTF"), url: "http://www.cnn.com", handler: :blah
    doc = @db['errors'].find.first
    doc['error'].should == 'Exception'
    doc['url'].should == 'http://www.cnn.com'
    doc['handler'].should == :blah
    doc['message'].should == 'WTF'
    doc['spider'].should == 'TestMopedSpider'
  end

end