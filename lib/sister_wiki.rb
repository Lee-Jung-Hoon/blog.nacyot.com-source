class SisterWiki
  attr_reader :documents
  
  CONFIG_FILE = "./config/sister_wiki.json"
  TMP_DIR = "./tmp/"

  def config
    @config || @config = JSON.parse(File.read(CONFIG_FILE))["sisters"]
  end
  
  def initialize(name = "default")
    set_sister_config
    init_documents_list
  end

  def set_sister_config
    @sister = config.find{|item| item["name"] == "default"}    
  end

  def tmp_documents_file
    TMP_DIR + @sister["name"]
  end
  
  def init_documents_list
    @documents = File.exists?(tmp_documents_file) ? read_documents_from_file : read_documents_from_url
  end

  def read_documents_from_file
    JSON.parse(File.open(tmp_documents_file).read)["documents"]
  end

  def read_documents_from_url
    create_documents_list
    JSON.parse(File.open(tmp_documents_file).read)["documents"]
  end
  
  def create_documents_list
    File.open(tmp_documents_file ,"w+") do |file|
      file.write(open(@sister["documents"]).read)
    end
  end

  def link(file, name)
    exists?(file) ? live_link(file, name) : dead_link(file, name)
  end

  def exists?(file)
    @documents.include?(file)
  end

  def live_link(file, name)
    write_live_link(file)
    "<span class='live_link'><a href='#{@sister["base_url"] + file}'>#{name}</a></span>"
  end

  def write_live_link(link)
    File.open(TMP_DIR + "live_links", "a+") do |file|
      file.write(link + "\n")
    end
  end
  
  def dead_link(file, name)
    write_dead_link(file)
    "<span class='dead_link'><a href='#{@sister["base_url"] + file}' rel='nofollow'>#{name}</a></span>"
  end

  def write_dead_link(link)
    File.open(TMP_DIR + "dead_links", "a+") do |file|
      file.write(link + "\n")
    end
  end
end
