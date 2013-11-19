# Patch to allow open-uri to follow safe (http to https) and unsafe redirections (https to http).
# Original gist URL:
# https://gist.github.com/1271420
#
# Relevant issue:
# http://redmine.ruby-lang.org/issues/3719
#
# Source here:
# https://github.com/ruby/ruby/blob/trunk/lib/open-uri.rb

module OpenURI
  class <<self
    alias_method :open_uri_original, :open_uri
    alias_method :redirectable_cautious?, :redirectable?

    def redirectable_safe?(uri1, uri2)
      uri1.scheme.downcase == uri2.scheme.downcase || (uri1.scheme.downcase == "http" && uri2.scheme.downcase == "https")
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
    case allow_redirections
    when :safe
      class << self
        remove_method :redirectable?
        alias_method  :redirectable?, :redirectable_safe?
      end
    when :all
      class << self
        remove_method :redirectable?
        alias_method  :redirectable?, :redirectable_all?
      end
    else
      class << self
        remove_method :redirectable?
        alias_method  :redirectable?, :redirectable_cautious?
      end
    end

    self.open_uri_original name, *rest, &block
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
