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

    describe ":allow_safe_redirections" do
      it "should allow HTTP => HTTPS redirections when true" do
        expect {
          open("http://safe.com", :allow_safe_redirections => true)
        }.to_not raise_error
      end

      it "should disallow HTTP => HTTPS redirections when false" do
        expect {
          open("http://safe.com", :allow_safe_redirections => false)
        }.to raise_error(RuntimeError, "redirection forbidden: http://safe.com -> https://safe.com/")
      end

      it "should follow safe redirection when true" do
        open("http://safe.com", :allow_safe_redirections => true).read.should == "Hello, this is Safe."
      end

      it "should disallow HTTPS => HTTP redirections" do
        expect {
          open("https://unsafe.com", :allow_safe_redirections => true)
        }.to raise_error(RuntimeError, "redirection forbidden: https://unsafe.com -> http://unsafe.com/")
      end

    end

    describe ":allow_unsafe_redirections" do
      it "should allow HTTPS => HTTP redirections when true" do
        expect {
          open("https://unsafe.com", :allow_unsafe_redirections => true)
        }.to_not raise_error
      end

      it "should allow HTTP => HTTPS redirections when true" do
        expect {
          open("http://safe.com", :allow_unsafe_redirections => true)
        }.to_not raise_error
      end

      it "should disallow HTTPS => HTTP redirections when false" do
        expect {
          open("https://unsafe.com", :allow_unsafe_redirections => false)
        }.to raise_error(RuntimeError, "redirection forbidden: https://unsafe.com -> http://unsafe.com/")
      end

      it "should follow unsafe redirection when true" do
        open("https://unsafe.com", :allow_unsafe_redirections => true).read.should == "Hello, this is Unsafe."
      end

      it "should follow safe redirection when true" do
        open("http://safe.com", :allow_safe_redirections => true).read.should == "Hello, this is Safe."
      end

    end
  end
end
