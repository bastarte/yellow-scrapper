class Controller
  # DEPARTEMENTS = %w[D044 D059 D013 D067].freeze
  DEPARTEMENTS = %w[D059].freeze
  SEARCH = 'agence interim btp'.freeze

  def import_from_web
    all_agencies = []
    scrapper = ScrapperService.new
    DEPARTEMENTS.each do |dept|
      page = 1
      loop do
        attributes = { start: page, search: SEARCH, dept: dept }
        scrapped_agencies = scrapper.call(attributes)
        pp scrapped_agencies.count
        scrapped_agencies.count > 0 ? all_agencies += scrapped_agencies : break
        page += 1
        page >= 30 ? break : 1 == 1 # arbitrary limit of pages. Can be increased if makes business sense
      end
    end
    save_csv(all_agencies)
  end

  private

  def save_csv(all_agencies)
    CSV.open('data/data.csv', 'wb') do |csv|
      csv << all_agencies.first.keys # adds the attributes name on the first line
      all_agencies.each do |agency_data|
        csv << agency_data.values
      end
    end
  end
end
