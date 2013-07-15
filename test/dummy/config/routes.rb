Rails.application.routes.draw do

  mount EveData::Engine => "/eve_data"
end
