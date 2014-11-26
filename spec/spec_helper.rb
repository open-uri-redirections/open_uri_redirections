# -*- encoding: utf-8 -*-

$: << File.join(File.dirname(__FILE__), "/../lib")
require 'open_uri_redirections'
require 'fakeweb'

FakeWeb.allow_net_connect = false

$samples_dir = File.dirname(__FILE__) + '/samples'

#######################
# Faked web responses #
#######################

FakeWeb.register_uri(:get, "http://safe.com/",    :response => open("#{$samples_dir}/http_safe.response").read)
FakeWeb.register_uri(:get, "https://safe.com/",   :response => open("#{$samples_dir}/https_safe.response").read)

FakeWeb.register_uri(:get, "http://safe2.com/",   :response => open("#{$samples_dir}/http_safe2.response").read)

FakeWeb.register_uri(:get, "https://unsafe.com/", :response => open("#{$samples_dir}/https_unsafe.response").read)
FakeWeb.register_uri(:get, "http://unsafe.com/",  :response => open("#{$samples_dir}/http_unsafe.response").read)
