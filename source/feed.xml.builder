xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_url = "http://blog.nacyot.com/"
  xml.title "Nacyot의 프로그래밍 이야기"
  xml.subtitle "Nacyot의 프로그래밍 이야기"
  xml.id URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
  xml.updated(blog.articles.first.date.to_time.iso8601) unless blog.articles.empty?
  xml.author { xml.name "nacyot(Daekwon Kim)" }

  blog.articles[0..5].each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
      xml.id URI.join(site_url, article.url)
      xml.published article.date.to_time.iso8601
      xml.updated File.mtime(article.source_file).iso8601
      xml.author { xml.name "nacyot(Daekwon Kim)" }
      # xml.summary article.summary, "type" => "html"
      file_content = IO.read(article.source_file)
      index = file_content.index("\n---") + 4
      article_body = markdown_engine.render(file_content[index..-1])  
      xml.content article_body, "type" => "html"
    end
  end
end
