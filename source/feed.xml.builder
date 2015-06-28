recommandation = <<REC
<br/>
<br/>
<div>
  <strong>이 글이 도움이 되셨나요?</strong>
  <div>
    <a href='http://blog.nacyot.com' target="_blank">
      nacyot의 프로그래밍 이야기 메인으로 이동하기
    </a>
  </div>
  <div>
    <a href='https://twitter.com/intent/follow?screen_name=nacyo_t' target="_blank">
      <img style='display: inline' width='20' height='20' src='/images/twitter.png' />
      Twitter에서 nacyot 팔로우하기
    </a>
  </div>
</div>
REC

xml.instruct!
xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom' do
  site_url = 'http://blog.nacyot.com/'
  xml.title 'Nacyot의 프로그래밍 이야기'
  xml.subtitle 'Nacyot의 프로그래밍 이야기'
  xml.id URI.join(site_url, blog.options.prefix.to_s)
  xml.link 'href' => URI.join(site_url, blog.options.prefix.to_s)
  xml.link 'href' => URI.join(site_url, current_page.path), 'rel' => 'self'
  xml.updated(blog.articles.first.date.to_time.iso8601) unless blog.articles.empty?
  xml.author { xml.name 'nacyot(Daekwon Kim)' }

  blog.articles[0..9].each do |article|
    xml.entry do
      xml.title article.title
      xml.link 'rel' => 'alternate', 'href' => URI.join(site_url, article.url)
      xml.id URI.join(site_url, article.url)
      xml.published article.date.to_time.localtime.iso8601
      xml.updated File.mtime(article.source_file).localtime.iso8601
      xml.author { xml.name 'nacyot(Daekwon Kim)' }
      # xml.summary article.summary, 'type' => 'html'
      title_image = "<img src='#{article.data.title_image}' />"
      article_body = ArticleWithCustomEngine.new(article.source_file).body
      xml.content title_image + article_body + recommandation, 'type' => 'html'
    end
  end
end
