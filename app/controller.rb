class Controller
  def import_from_web
    page = 0
    all_agencies = []
    scrapper = ScrapperService.new
    loop do
      attributes = { start: page * 10 }
      page += 1
      agencies = scrapper.call(attributes)
      agencies.last == all_agencies.last ? break : all_agencies += agencies
    end
    save_csv(all_agencies)
  end

  private

  def save_csv(all_agencies)
    CSV.open('../data/data.csv', 'wb') do |csv|
      csv << all_agencies.first.keys # adds the attributes name on the first line
      all_agencies.each do |agency_data|
        csv << agency_data.values
      end
    end
  end
end
