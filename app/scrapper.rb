class ScrapperService
  # PREFIX = 'https://www.pagesjaunes.fr/annuaire/chercherlespros'.freeze

  def call(attributes = { start: 0 })
    @url = "https://www.pagesjaunes.fr/annuaire/chercherlespros?quoiqui=agence%20interim%20btp&ou=Loire-Atlantique%20%2844%29&idOu=D044&page=3&contexte=SZYmn5mkbDwBxawUHB0Su3eKL16bkxx3e0d5jKAkSaA%3D&proximite=0&quoiQuiInterprete=agence%20interim%20btp"

    store_locally

    html_file = File.open('data/document.html')
    html_doc  = Nokogiri::HTML(html_file, nil, 'utf-8')

    agencies = []
    html_doc.search('li.bi-bloc.blocs.clearfix.bi-pro').each do |result|
      @agency = {}
      business_name_raw     = result.search('.row-denom') # Business name
      address_raw           = result.search('.main-adresse-container.row-adresse.with-adresse.with-horaire-chaudes') # Address
      tags_raw              = result.search('.activites-mentions') # tags
      activities_raw        = result.search('.zone-cvi-cviv') # activities
      keywords_raw          = result.search('.zone-mots-cles.with-cris') # keywords
      website_raw           = result.search('li.bi-site-internet a')

      pp parse_business_name(business_name_raw)
      pp parse_address(address_raw)
      pp parse_tags(tags_raw)
      pp parse_activities_raw(activities_raw)
      pp parse_keywords_raw(keywords_raw)
      pp parse_website_raw(website_raw)
      # pp "website_raw", website_raw
      agencies << @agency
      break

    end
    agencies
  end

  private

  def store_locally
    # store_in_file
    unless File.file?('data/document.html') # tries to get page locally
    # unless false # forces to get page from the web
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
    a.at("span").children.remove # we don't need this span's content
    @agency[:address] = a.text.strip.gsub(/\n/," ")
  end

  def parse_tags(tags_raw)
    @agency[:tags] = tags_raw.text.strip
  end

  def parse_activities_raw(activities_raw)
    @agency[:activities] = activities_raw.text.strip.gsub(/\n/," ")
  end

  def parse_keywords_raw(keywords_raw)
    @agency[:keywords] = keywords_raw.text.strip
  end

  def parse_website_raw(website_raw)
    pp website_raw
    website_raw.css(".pj-lb.pj-link").last.text
  end

end
