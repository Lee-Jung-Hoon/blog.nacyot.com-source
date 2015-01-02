module MarkdownHelper
  def markdown_engine
    Redcarpet::Markdown.new(::HTMLwithPygments.new(:with_toc_data => true),
                            :autolink => true,
                            :space_after_headers => true,
                            :fenced_code_blocks => true,
                            :strikethrough => true,
                            :underline => false,
                            :footnotes => true,
                            )
  end

  def self.markdown_engine
    Redcarpet::Markdown.new(::HTMLwithPygments.new(:with_toc_data => true),
                            :autolink => true,
                            :space_after_headers => true,
                            :fenced_code_blocks => true,
                            :strikethrough => true,
                            :underline => false,
                            :footnotes => true,
                            )
  end
  
  def toc_engine
    return Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC)
  end
end

class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, :lexer => language, options: {linespans: 'line'})
  end

  def preprocess(document)
    render_sister_wiki document
  end

  def render_sister_wiki(document)
    wiki = SisterWiki.new

    document.gsub(/\[\[([.a-zA-Zㄱ-힣|\-_ ][.a-zA-Zㄱ-힣|\-_0-9 ]*?)\]\]/) do |m|
      match = $1
      if match
        if match =~ /\|/
          name, filename = match.split("|").map{|item| item.downcase}
          wiki.link(filename, name)
        else
          puts "match:" + match.to_s
          wiki.link(match.downcase, match)
        end
      end
    end
  end

  def postprocess(document)
    document = render_ipython(document)
    document = render_toc(document)
    document
  end

  def render_ipython(document)
    document.gsub(/\{\{ipython:(.*?)\}\}/) do |m|
      filename = $1
      render_ipynb filename
      
      target = "./source/iruby/#{filename}.html"
      return document unless File.exist?(target)
      
      File.read(target).
        gsub(/In&nbsp;\[(.*?)\]:/){  "#{$1}번째 입력:" }.
        gsub(/Out\[(.*?)\]:/){ "#{$1}번째 평가:" }.
        gsub(/<span class="ansigrey".*?<\/span>.*?\n/, "").
        gsub("\n\n</pre>", "\n</pre>").
        gsub("output_stdout\">\n<pre>","output_stdout\">\n<div class=\"prompt output_prompt\">출력:</div><pre>")
    end
  end
  
  def render_toc(document)
    document.gsub(/<h([1-6]) id=['"](.*?)['"]>(.*?)<\/h[1-6]>/) do |m|
      "<h#{$1}><a name='#{$2}'>#{$3}</a> <span class='to_toc'><a href='#toc'><i class='fa fa-flag'></i></a></span></h#{$1}>"
    end
  end

  def render_ipynb(filename)
    cmd = "ipython nbconvert --to html --template basic ./source/iruby/#{filename}.ipynb --output ./source/iruby/#{filename}"
    system(cmd)
  end
end
