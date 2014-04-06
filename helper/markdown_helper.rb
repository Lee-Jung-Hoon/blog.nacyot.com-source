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

  def preprocess(document)
    document.gsub!(/\[\[ipython:(.*?)\]\]/) do |m|
      cmd = "ipython nbconvert --to html --template basic ./source/iruby/#{$1}.ipynb --output ./source/iruby/#{$1}"
      system(cmd)
      File.read("./source/iruby/#{$1}.html")
    end

    document
  end
end
