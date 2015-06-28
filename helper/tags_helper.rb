module TagsHelper
  def generate_tagname(tagname)
    tag = data.tags[tagname]
    return tagname + '(!)' unless tag

    ko_name = tag.fetch('ko', nil)
    en_name = tag.fetch('en', nil)

    if ko_name && en_name
      return "#{ko_name}(#{en_name})"
    elsif ko_name
      return "#{ko_name}(#{tagname})"
    elsif en_name
      return en_name
    end
  end

  def article_title_tag(article)
    # return link_to(article.title, article.data.gist) if article.data.gist
    link_to(article.title, article)
  end

  def more_read_link_tag(article)
    # return link_to("전문 읽기", article.data.gist) if article.data.gist
    link_to("전문 읽기", article)
  end
end
