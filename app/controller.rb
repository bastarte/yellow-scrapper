class Controller
  def import_from_web
    all_agencies = []
    scrapper = ScrapperService.new
    ["D044", "D059", "D013", "D067"].each do |dept|
      page = 1
      loop do
        attributes = { start: page, search: "agence interim btp", dept: dept }
        scraped = scrapper.call(attributes)
        pp scraped.count
        scraped.count > 0 ? all_agencies += scraped : break
        page += 1
        page >= 30 ? break : 1 == 1
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
