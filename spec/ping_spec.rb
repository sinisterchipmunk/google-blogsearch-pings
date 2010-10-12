require 'spec_helper'

=begin
  Name of site
  URL of site
  URL of the page to be checked for changes
  URL of RSS, RDF, or Atom feed
  Optional a name (or "tag") categorizing your site content. You may delimit multiple values by using the '|' character.
=end

describe Google::Blogsearch::Ping do
  subject { Google::Blogsearch::Ping.new("Thoughts in Computation", "http://thoughtsincomputation.com/rss") }
  
  it "should set name" do
    subject.name.should == "Thoughts in Computation"
  end
  
  it "should set feed URL" do
    subject.feed_url.should == "http://thoughtsincomputation.com/rss"
  end
  
  it "should infer site URL" do
    subject.site_url.should == "http://thoughtsincomputation.com/"
  end
  
  it "should infer update URL" do
    subject.update_url.should == "http://thoughtsincomputation.com/"
  end
  
  it "should have no tags" do
    subject.tags.should == []
  end
  
  it "should send the ping" do
    client = XMLRPC::Client.new2("http://blogsearch.google.com/ping/RPC2")
    XMLRPC::Client.should_receive(:new).and_return(client)
    subject.ping!
  end
  
  context "with site and update URLs" do
    subject { Google::Blogsearch::Ping.new("Thoughts in Computation", "http://thoughtsincomputation.com/rss",
                                           :site => "http://www.thoughtsincomputation.com",
                                           :updated => "http://www.thoughtsincomputation.com") }
    
    it "should set the site URL" do
      subject.site_url.should == "http://www.thoughtsincomputation.com"
    end
    
    it "should set the updated URL" do
      subject.update_url.should == "http://www.thoughtsincomputation.com"
    end
  end
  
  context "with tags" do
    subject { Google::Blogsearch::Ping.new("Thoughts in Computation", "http://thoughtsincomputation.com/rss",
                                           :tags => %w(ruby rails)) }
    
    it "should construct the tags parameter" do
      subject.tags_param.should == "ruby|rails"
    end

    it "should have tags" do # duh :P
      subject.tags.should == ["ruby", "rails"]
    end
  end
end
