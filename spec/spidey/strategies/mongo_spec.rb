require 'spec_helper'

describe Spidey::Strategies::Mongo do
  class TestSpider < Spidey::AbstractSpider
    include Spidey::Strategies::Mongo
    handle "http://www.cnn.com", :process_home
    
    def result_key(data)
      data[:detail_url]
    end
  end
  
  before(:each) do
    @db = Mongo::Connection.new['spidey-mongo-test']
    @spider = TestSpider.new(
      url_collection: @db['urls'],
      result_collection: @db['results'],
      error_collection: @db['errors'])
  end
  
  after(:each) do
    %w{ urls results errors }.each{ |col| @db[col].drop }
  end
  
  it "should add initial URLs to collection" do
    doc = @db['urls'].find_one(url: "http://www.cnn.com")
    doc['handler'].should == :process_home
  end
  
  it "should not add duplicate URLs" do
    @spider.send :handle, "http://www.cnn.com", :process_home
    @db['urls'].find(url: "http://www.cnn.com").count.should == 1
  end
  
  it "should add results" do
    @spider.record detail_url: 'http://www.cnn.com', foo: 'bar'
    @db['results'].count.should == 1
    doc = @db['results'].find_one
    doc['detail_url'].should == 'http://www.cnn.com'
    doc['foo'].should == 'bar'
  end
  
  it "should update existing result" do
    @db['results'].insert key: 'http://foo.bar', detail_url: 'http://foo.bar'
    @spider.record detail_url: 'http://foo.bar', foo: 'bar'
    @db['results'].count.should == 1
  end
  
  it "should add error" do
    @spider.add_error error: Exception.new("WTF"), url: "http://www.cnn.com", handler: :blah
    doc = @db['errors'].find_one
    doc['error'].should == 'Exception'
    doc['url'].should == 'http://www.cnn.com'
    doc['handler'].should == :blah
    doc['message'].should == 'WTF'
  end
  
end