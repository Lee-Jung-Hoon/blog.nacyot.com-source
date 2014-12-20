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
  blog.taglink = "tags/{tag}.html"
  blog.tag_template = "tags/tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 1
  blog.page_link = "page/{num}"
end

page "/*", :layout => "layout"
page "/articles/*", :layout => "blog"
page "/feed.xml", layout: false
page "/sitemap.xml", layout: false

# Directory configure
set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

Time.zone = 'Seoul'

after_configuration do
  sprockets.append_path File.join(File.expand_path(File.dirname(__FILE__)), 'assets', 'components')
end

load "./helper/markdown_helper.rb"
load "./helper/article_helper.rb"
load "./lib/sister_wiki.rb"
load "./lib/article_with_custom_engine.rb"
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

set :domain, "http://blog.nacyot.com"
set :site_title, "nacyot의 프로그래밍 이야기"
set :site_description, "blog.nacyot.com은 루비 프로그래머 nacyot이 프로그래밍을 주제로 운영하고 있는 블로그입니다."
set :site_title_image, "http://blog.nacyot.com/images/nacyot.jpeg"
set :author, "nacyot(Daekwon Kim)"
set :author_facebook, "https://www.facebook.com/KimDaeKwon"
set :author_twitter, "@nacyo_t"

configure :build do
  activate :relative_assets
end

class Middleman::Application
  def count_links(file)
    live_links = File.open(file).
      each_line.
      to_a.
      map(&:chop).
      group_by{|item|item}.
      map{|key,value| {key.to_sym => value.count / 2}}.
      inject({}){|sum, item| sum.merge(item)}.
      to_json
  end

  def remove_tmps
    FileUtils.rm(Dir["./tmp/*"])  
  end
end

before do
end

after_build do
  live_links = count_links("./tmp/live_links")
  File.open("./build/live_links.json", "w+") do |file|
    file.write(live_links)
  end

  dead_links = count_links("./tmp/dead_links")
  File.open("./build/dead_links.json", "w+") do |file|
    file.write(dead_links)
  end

  remove_tmps
end

