class ArticleWithCustomEngine
  include MarkdownHelper
  
  def initialize(file)
    @content = File.read(file)
    @index = @content.index("\n---") + 4
    @summary_index = @content.index("<!--more-->") - 1
  end

  def body
    markdown_engine.render(@content[@index..-1])
  end

  def summary
    markdown_engine.render(@content[@index..@summary_index])
  end

  def toc
    toc_engine.render(@content[@index..-1].gsub(/```(.*?)```/m, ""))
  rescue
    toc_engine.render(@content.gsub(/```(.*?)```/m, ""))
  end
end
