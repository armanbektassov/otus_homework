require File.expand_path '../server.rb', __FILE__
require "prometheus/middleware/collector"
require "prometheus/middleware/exporter"

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

run Rack::URLMap.new({
                       '/' => Public,
                       '/api' => Api
                     })