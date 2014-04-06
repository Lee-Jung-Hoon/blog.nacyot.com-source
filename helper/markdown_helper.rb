module MarkdownHelper
  def markdown_engine
    Redcarpet::Markdown.new(HTMLwithPygments,
                            :autolink => true,
                            :space_after_headers => true,
                            :fenced_code_blocks => true,
                            :strikethrough => true,
                            :underline => false,
                            :footnotes => true,
                            )
  end
end

class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, :lexer => language, options: {linespans: 'line'})
  end

  def postprocess(document)
    document.gsub!(/\[\[ipython:(.*?)\]\]/) do |m|
      filename = $1
      render_ipynb filename
      
      target = "./source/iruby/#{filename}.html"
      return document unless File.exist?(target)
      
      File.read(target).
        gsub(/In&nbsp;\[(.*?)\]:/){  "#{$1}번째 입력:" }.
        gsub(/Out\[(.*?)\]:/){ "#{$1}번째 평가:" }.
        gsub(/<span class="ansigrey".*?<\/span>.*?\n/, "")
    end

    document
  end

  def render_ipynb(filename)
    cmd = "ipython nbconvert --to html --template basic ./source/iruby/#{filename}.ipynb --output ./source/iruby/#{filename}"
    system(cmd)
  end
end
