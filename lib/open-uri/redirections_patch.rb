# Patch to allow open-uri to follow safe (http to https) and unsafe redirections (https to http).
# Original gist URL:
# https://gist.github.com/1271420
#
# Relevant issue:
# http://redmine.ruby-lang.org/issues/3719
#
# Source here:
# https://github.com/ruby/ruby/blob/trunk/lib/open-uri.rb
#
# Thread-safe implementation adapted from:
# https://github.com/obfusk/open_uri_w_redirect_to_https

module OpenURI
  class <<self
    alias_method :open_uri_original, :open_uri
    alias_method :redirectable_cautious?, :redirectable?

    def redirectable?(uri1, uri2)
      allow_redirections = Thread.current[:__open_uri_redirections__]

      # clear to prevent leaking (e.g. to block)
      Thread.current[:__open_uri_redirections__] = nil

      case allow_redirections
      when :safe
        redirectable_safe? uri1, uri2
      when :all
        redirectable_all? uri1, uri2
      else
        redirectable_cautious? uri1, uri2
      end
    end

    def redirectable_safe?(uri1, uri2)
      redirectable_cautious?(uri1, uri2) || (uri1.scheme.downcase == "http" && uri2.scheme.downcase == "https")
    end

    def redirectable_all?(uri1, uri2)
      redirectable_safe?(uri1, uri2) || (uri1.scheme.downcase == "https" && uri2.scheme.downcase == "http")
    end
  end

  # Patches the original open_uri method to accept the :allow_redirections option
  #
  # :allow_redirections => :safe will allow HTTP => HTTPS redirections.
  # :allow_redirections => :all  will allow HTTP => HTTPS and HTTPS => HTTP redirections.
  #
  def self.open_uri(name, *rest, &block)
    options = self.first_hash_argument(rest)
    allow_redirections = options.delete :allow_redirections if options
    Thread.current[:__open_uri_redirections__] = allow_redirections

    begin
      self.open_uri_original name, *rest, &block
    ensure
      # clear (redirectable? might not be called due to an exception)
      Thread.current[:__open_uri_redirections__] = nil
    end
  end

  private

  # OpenURI::open can receive different kinds of arguments, like a string for the mode
  # or an integer for the permissions, and then a hash with options like UserAgent, etc.
  #
  # This method helps us find this options hash, as it is where our :allow_redirections
  # option will reside.
  def self.first_hash_argument(arguments)
    arguments.select {|arg| Hash === arg}.first
  end
end
