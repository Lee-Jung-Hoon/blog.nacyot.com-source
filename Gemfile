# If you have OpenSSL installed, we recommend updating
# the following line to use "https"
source 'http://rubygems.org'

gem "middleman", "~> 3.2.1"
gem "middleman-blog", "~> 3.5.1"

# For feed.xml.builder
gem "builder", "~> 3.0"

# Live-reloading plugin
gem "middleman-livereload", "~> 3.1.0"

# For faster file watcher updates on Windows:
gem "wdm", "~> 0.1.0", :platforms => [:mswin, :mingw]

# Base gems
gem "rake"
gem "dotenv"

# Formatter gems
gem "haml"
gem 'therubyracer'
gem "less"
gem "redcarpet", github: "vmg/redcarpet"
gem "pygments.rb"

# Watch gems
gem "guard-rspec"
gem "guard-middleman"

group :development, :test do
  # Test gems
  gem 'rspec'
  gem 'coveralls', require: false
  gem 'faker'
  gem 'shoulda'
  gem "capybara"
end
