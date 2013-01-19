# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), "/spec_helper")

describe "OpenURI" do
  describe "#open" do
    describe "Default settings" do
      it "should disallow HTTP => HTTPS redirections" do
        expect {
          open("http://safe.com")
        }.to raise_error(RuntimeError, "redirection forbidden: http://safe.com -> https://safe.com/")
      end

      it "should disallow HTTPS => HTTP redirections" do
        expect {
          open("https://unsafe.com")
        }.to raise_error(RuntimeError, "redirection forbidden: https://unsafe.com -> http://unsafe.com/")
      end
    end

    describe ":allow_redirections => :safe" do
      it "should allow HTTP => HTTPS redirections" do
        expect {
          open("http://safe.com", :allow_redirections => :safe)
        }.to_not raise_error
      end

      it "should disallow HTTPS => HTTP redirections" do
        expect {
          open("https://unsafe.com", :allow_redirections => :safe)
        }.to raise_error(RuntimeError, "redirection forbidden: https://unsafe.com -> http://unsafe.com/")
      end

      it "should follow safe redirections" do
        open("http://safe.com", :allow_redirections => :safe).read.should == "Hello, this is Safe."
      end
    end

    describe ":allow_redirections => :all" do
      it "should allow HTTP => HTTPS redirections" do
        expect {
          open("http://safe.com", :allow_redirections => :all)
        }.to_not raise_error
      end

      it "should allow HTTPS => HTTP redirections" do
        expect {
          open("https://unsafe.com", :allow_redirections => :all)
        }.to_not raise_error
      end

      it "should follow safe redirections" do
        open("http://safe.com", :allow_redirections => :all).read.should == "Hello, this is Safe."
      end

      it "should follow unsafe redirections" do
        open("https://unsafe.com", :allow_redirections => :all).read.should == "Hello, this is Unsafe."
      end
    end
  end
end
