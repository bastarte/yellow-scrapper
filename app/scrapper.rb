class ScrapperService
  # PREFIX = 'https://www.pagesjaunes.fr/annuaire/chercherlespros'.freeze

  def call(attributes = { start: 0, search: "interim", dept: "D044" })
    @url = "https://www.pagesjaunes.fr/annuaire/chercherlespros?quoiqui=#{attributes[:search]}&idOu=#{attributes[:dept]}&page=#{attributes[:start]}&proximite=0"
    pp @url
    store_locally

    html_file = File.open('data/document.html')
    html_doc  = Nokogiri::HTML(html_file, nil, 'utf-8')

    agencies = []
    html_doc.search('li.bi-bloc.blocs.clearfix.bi-pro').each do |result|
      print "*     new entry    : "
      @agency = {}
      business_name_raw     = result.search('.row-denom') # Business name
      address_raw           = result.search('.main-adresse-container.row-adresse.with-adresse.with-horaire-chaudes') # Address
      tags_raw              = result.search('.activites-mentions') # tags
      activities_raw        = result.search('.zone-cvi-cviv') # activities
      keywords_raw          = result.search('.zone-mots-cles.with-cris') # keywords
      # website_raw           = result.search('li.bi-site-internet a')
      website_raw           = result.search('footer')

      @agency[:search] = attributes[:search]
      @agency[:departement] = attributes[:dept][-3..-1]
      pp parse_business_name(business_name_raw)
      parse_address(address_raw)
      parse_tags(tags_raw)
      parse_activities_raw(activities_raw)
      parse_keywords_raw(keywords_raw)
      parse_website_raw(website_raw)
      agencies << @agency

    end
    agencies
  end

  private

  def store_locally
    # store_in_file
    # unless File.file?('data/document.html') # tries to get page locally
    unless false # forces to get page from the web
      html_file = URI.parse(@url).open.read
      html_doc  = Nokogiri::HTML(html_file)
      File.write('data/document.html', html_doc.search('#listResults'))
    end
  end

  def parse_business_name(business_name_raw)
    @agency[:business_name] = business_name_raw.css(".denomination-links.pj-link").text.strip
  end

  def parse_address(address_raw)
    a = address_raw.css(".adresse.pj-lb.pj-link")
    a.at("span").children.remove unless a.at("span").nil? # we don't need this span's content
    @agency[:address] = a.text.strip.gsub(/\n/, ' ')
  end

  def parse_tags(tags_raw)
    @agency[:tags] = tags_raw.text.strip
  end

  def parse_activities_raw(activities_raw)
    @agency[:activities] = activities_raw.text.strip.gsub(/\n/, ' ')
  end

  def parse_keywords_raw(keywords_raw)
    @agency[:keywords] = keywords_raw.text.strip
  end

  def parse_website_raw(website_raw)
    # the data can appear in different way. Path2 data is hidden with JS so we can't get it for now
    path1 = "li.bi-site-internet a.pj-lb.pj-link"
    path2 = "li.item.hidden-phone.site-internet.SEL-internet a.pj-link"

    if website_raw.css(path1).last # last because other lines are Facebook and such
      data = website_raw.css(path1).last
      @agency[:website] = data.text
    elsif website_raw.css(path2)[0] # 0 because next items are noise
      data = website_raw.css(path2)[0]['href']
      @agency[:website] = data
    else
      @agency[:website] = "NC"
    end
    @agency[:website] = "Adresse irrécupérable" if %w[NC # javascript:].include?(@agency[:website])
  end

end
