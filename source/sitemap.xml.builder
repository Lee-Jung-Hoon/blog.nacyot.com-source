xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc config[:domain]
    xml.lastmod blog.articles.first.date.iso8601
    xml.changefreq "weekly"
    xml.priority 1
  end

  blog.articles.each do |article|
    xml.url do
      xml.loc config[:domain] + article.url
      xml.lastmod article.date.iso8601
      xml.changefreq "monthly"
      xml.priority 1
    end
  end 
end
