activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"
  # blog.permalink = "{year}/{month}/{day}/{title}.html"

  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.summary_separator = /<!--more-->/
  blog.summary_length = 250
  
  blog.layout = "layouts/blog"
  blog.permalink = "articles/:title"
  blog.sources = "articles/:title.html"
  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 1
  blog.page_link = "page/{num}"
end

page "/*", :layout => "layout"
page "/articles/*", :layout => "blog"
page "/feed.xml", layout: false

# Directory configure
set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

after_configuration do
  sprockets.append_path File.join(File.expand_path(File.dirname(__FILE__)), 'assets', 'components')
end


require "./helper/markdown_helper.rb"
require "./helper/article_helper.rb"
helpers MarkdownHelper
helpers ArticleHelper

# Markdown configure
set :markdown_engine, :redcarpet
# set :markdown, :fenced_code_blocks => true, :smartypants => true

# Haml configure
set :haml, { ugly: true }

# Another configure
activate :directory_indexes

set :relative_links, true

configure :build do
  activate :relative_assets
end
