require 'open-uri'
require 'nokogiri'
require 'csv'

require_relative 'app/scrapper'
require_relative 'app/controller'

controller = Controller.new
controller.import_from_web
