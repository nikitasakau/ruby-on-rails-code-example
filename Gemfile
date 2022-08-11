source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'rails', '~> 6.0.3', '>= 6.0.3.2'

gem 'pg', '~> 1.2.3'

gem 'puma', '~> 4.1'

gem 'bootsnap', '>= 1.4.2', require: false

gem 'rack-cors'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'datarockets-style'
  gem 'pry'
  gem 'rspec-rails', '~> 4.0.1'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers', '~> 4.0'
end

group :development do
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'

gem 'bcrypt', '~> 3.1'

gem 'jwt', '~> 2.2'

gem 'pundit', '~> 2.1'

gem 'user_agent_parser', '~> 2.7'

gem 'jsonapi-serializer', '~> 2.1'

gem 'haml-rails', '~> 2.0'

gem 'ancestry', '~> 3.2'

gem 'sidekiq', '~> 6.2'
