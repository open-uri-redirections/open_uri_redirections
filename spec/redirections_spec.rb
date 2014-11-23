# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), "/spec_helper")

class << OpenURI
  alias_method :open_uri_original__, :open_uri_original
end

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

      it "should follow safe redirections with block" do
        expect { |b|
          open("http://safe.com", :allow_redirections => :safe, &b)
        }.to yield_control
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

      it "should follow safe redirections with block" do
        expect { |b|
          open("http://safe.com", :allow_redirections => :all, &b)
        }.to yield_control
      end

      it "should follow unsafe redirections with block" do
        expect { |b|
          open("https://unsafe.com", :allow_redirections => :all, &b)
        }.to yield_control
      end
    end

    describe "passing arguments down the stack" do
      it "should disallow HTTP => HTTPS redirections" do
        expect {
          open("http://safe.com", 'r', 0444, "User-Agent" => "Mozilla/5.0")
        }.to raise_error(RuntimeError, "redirection forbidden: http://safe.com -> https://safe.com/")
      end

      it "should allow HTTP => HTTPS redirections" do
        expect {
          open("http://safe.com", 'r', 0444, "User-Agent" => "Mozilla/5.0", :allow_redirections => :safe)
        }.to_not raise_error
      end

      it "should pass the arguments down the stack" do
        OpenURI.should_receive(:open_uri_original).with(an_instance_of(URI::HTTP), "r", 0444, { "User-Agent" => "Mozilla/5.0" })

        open("http://safe.com", 'r', 0444, "User-Agent" => "Mozilla/5.0", :allow_redirections => :safe)
      end
    end

    describe "threads" do
      it "works" do
        allow(OpenURI).to receive(:open_uri_original) { |*a,&b| sleep rand; OpenURI.open_uri_original__ *a, &b }
        ts = []
        Thread.abort_on_exception = true
        begin
          100.times {
            ts << Thread.new {
              expect {
                open("http://safe.com")
              }.to raise_error(RuntimeError, "redirection forbidden: http://safe.com -> https://safe.com/")
            }
            ts << Thread.new {
              expect {
                open("http://safe.com", :allow_redirections => :safe)
              }.to_not raise_error
            }
            ts << Thread.new {
              expect {
                open("https://unsafe.com")
              }.to raise_error(RuntimeError, "redirection forbidden: https://unsafe.com -> http://unsafe.com/")
            }
            ts << Thread.new {
              expect {
                open("https://unsafe.com", :allow_redirections => :safe)
              }.to raise_error(RuntimeError, "redirection forbidden: https://unsafe.com -> http://unsafe.com/")
            }
          }
        ensure
          ts.each(&:join)
        end
      end
    end
  end
end
