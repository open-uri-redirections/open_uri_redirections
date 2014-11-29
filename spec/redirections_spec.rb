# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), '/spec_helper')

class << OpenURI
  alias_method :open_uri_original__, :open_uri_original
end

describe 'OpenURI' do
  describe '#open' do
    describe 'Default settings' do
      it 'should disallow HTTP => HTTPS redirections' do
        expect {
          open('http://safe.com')
        }.to raise_error(RuntimeError, safe_forbidden_msg)
      end

      it 'should disallow HTTPS => HTTP redirections' do
        expect {
          open('https://unsafe.com')
        }.to raise_error(RuntimeError, unsafe_forbidden_msg)
      end
    end

    describe ':allow_redirections => :safe' do
      it 'should allow HTTP => HTTPS redirections' do
        expect {
          open('http://safe.com', :allow_redirections => :safe)
        }.to_not raise_error
      end

      it 'should disallow HTTPS => HTTP redirections' do
        expect {
          open('https://unsafe.com', :allow_redirections => :safe)
        }.to raise_error(RuntimeError, unsafe_forbidden_msg)
      end

      it 'should follow safe redirections' do
        expect(
          open('http://safe.com', :allow_redirections => :safe).read
        ).to eq('Hello, this is Safe.')
      end

      it 'should follow safe double redirections' do
        expect(
          open('http://safe2.com', :allow_redirections => :safe).read
        ).to eq('Hello, this is Safe.')
      end

      it 'should follow safe redirections with block' do
        expect { |b|
          open('http://safe.com', :allow_redirections => :safe, &b)
        }.to yield_control
      end
    end

    describe ':allow_redirections => :all' do
      it 'should allow HTTP => HTTPS redirections' do
        expect {
          open('http://safe.com', :allow_redirections => :all)
        }.to_not raise_error
      end

      it 'should allow HTTPS => HTTP redirections' do
        expect {
          open('https://unsafe.com', :allow_redirections => :all)
        }.to_not raise_error
      end

      it 'should follow safe redirections' do
        expect(
          open('http://safe.com', :allow_redirections => :all).read
        ).to eq('Hello, this is Safe.')
      end

      it 'should follow unsafe redirections' do
        expect(
          open('https://unsafe.com', :allow_redirections => :all).read
        ).to eq('Hello, this is Unsafe.')
      end

      it 'should follow safe redirections with block' do
        expect { |b|
          open('http://safe.com', :allow_redirections => :all, &b)
        }.to yield_control
      end

      it 'should follow unsafe redirections with block' do
        expect { |b|
          open('https://unsafe.com', :allow_redirections => :all, &b)
        }.to yield_control
      end
    end

    describe 'passing arguments down the stack' do
      it 'should disallow HTTP => HTTPS redirections' do
        expect {
          open('http://safe.com', 'r', 0444, 'User-Agent' => 'Mozilla/5.0')
        }.to raise_error(RuntimeError, safe_forbidden_msg)
      end

      it 'should allow HTTP => HTTPS redirections' do
        expect {
          open('http://safe.com', 'r', 0444, 'User-Agent' => 'Mozilla/5.0', :allow_redirections => :safe)
        }.to_not raise_error
      end

      it 'should pass the arguments down the stack' do
        expect(OpenURI).to receive(:open_uri_original).with(an_instance_of(URI::HTTP), 'r', 0444, { 'User-Agent' => 'Mozilla/5.0' })

        open('http://safe.com', 'r', 0444, 'User-Agent' => 'Mozilla/5.0', :allow_redirections => :safe)
      end
    end

    describe 'threads' do
      it 'seems to work (could be false positive)' do
        allow(OpenURI).to receive(:open_uri_original) { |*a, &b| sleep rand; OpenURI.open_uri_original__ *a, &b }
        ts = []
        Thread.abort_on_exception = true

        begin
          100.times {
            ts << Thread.new {
              expect {
                open('http://safe.com')
              }.to raise_error(RuntimeError, safe_forbidden_msg)
            }
            ts << Thread.new {
              expect {
                open('http://safe.com', :allow_redirections => :safe)
              }.to_not raise_error
            }
            ts << Thread.new {
              expect {
                open('https://unsafe.com')
              }.to raise_error(RuntimeError, unsafe_forbidden_msg)
            }
            ts << Thread.new {
              expect {
                open('https://unsafe.com', :allow_redirections => :safe)
              }.to raise_error(RuntimeError, unsafe_forbidden_msg)
            }
          }
        ensure
          ts.each(&:join)
        end
      end
    end
  end

  private

  def safe_forbidden_msg
    'redirection forbidden: http://safe.com -> https://safe.com/'
  end

  def unsafe_forbidden_msg
    'redirection forbidden: https://unsafe.com -> http://unsafe.com/'
  end
end
