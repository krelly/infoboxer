source 'https://rubygems.org'

gemspec

# gem 'mediawiktory', github: 'molybdenum-99/mediawiktory', branch: 'develop'

gem 'rubygems-tasks'

group :docs do
  gem 'dokaz', git: 'https://github.com/zverok/dokaz.git'
  gem 'yard', '~> 0.9'
  gem 'redcarpet'
  #gem 'inch'
end

group :development do
  gem 'rake'
  gem 'ruby-prof' unless RUBY_PLATFORM.include?('java')
  gem 'byebug' unless RUBY_PLATFORM.include?('java')
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :test do
  gem 'rspec', '~> 3'
  gem 'rspec-its', '~> 1'
  gem 'vcr'
  gem 'webmock'
  gem 'timecop'
  gem 'saharspec' #, github: 'zverok/saharspec', branch: 'develop'
  gem 'coveralls', require: false
  gem 'yard-junk', github: 'zverok/yard-junk'
end
