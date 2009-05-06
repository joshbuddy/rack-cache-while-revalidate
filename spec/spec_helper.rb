require 'spec'
require 'rubygems'
require 'rack/cache'

#require 'rack-capabilities'
require '../rack-capabilities/lib/rack_capabilities' #working...

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rack_cache_while_revalidate'

Spec::Runner.configure do |config|
  
end
