require './server'
require "prometheus/middleware/collector"
require "prometheus/middleware/exporter"

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

run Sinatra::Application
