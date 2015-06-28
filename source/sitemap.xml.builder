xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc config[:domain]
    xml.lastmod blog.articles.first.date.iso8601
    xml.changefreq 'daily'
    xml.priority 1
  end

  blog.articles.each do |article|
    xml.url do
      xml.loc config[:domain] + article.url
      xml.lastmod article.date.iso8601
      xml.changefreq 'monthly'
      xml.priority 1
    end
  end

  blog.tags.each do |tag|
    xml.url do
      xml.loc config[:domain] + '/tags/' + tag[0]
      xml.lastmod tag[1].sort_by{|item| item.date}.reverse[0].date.iso8601
      xml.changefreq 'monthly'
      xml.priority 0.5
    end
  end
end
