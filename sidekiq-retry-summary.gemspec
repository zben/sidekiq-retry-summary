Gem::Specification.new do |s|
  s.name        = 'sidekiq-retry-summary'
  s.version     = '0.0.2'
  s.date        = '2018-07-01'
  s.summary     = "Adds summary page for retry queue to give you error count break down."
  s.description = "You get break down of retry queue by error messages and also direct link to view a list of identical errors"
  s.authors     = ["Ben Zhang"]
  s.email       = 'benzhangpro@gmail.com'
  s.files       = ["lib/sidekiq_retry_summary.rb"]
  s.homepage    =
    'http://rubygems.org/gems/sidekiq-retry-summary'
  s.license       = 'MIT'

  s.add_runtime_dependency 'sidekiq', ">= 3"
end
