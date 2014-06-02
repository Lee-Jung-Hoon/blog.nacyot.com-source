class ArticleWithCustomEngine
  attr_reader :body
  
  include MarkdownHelper
  
  def initialize(file)
    @content = File.read(file)
    @index = @content.index("\n---") + 4
    @body = markdown_engine.render(@content[@index..-1])
  end

  def toc
    toc_engine.render(@content[@index..-1].gsub(/```(.*?)```/m, ""))
  rescue
    toc_engine.render(@content.gsub(/```(.*?)```/m, ""))
  end
end
