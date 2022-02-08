require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'



get('/') do
    slim(:start)
end

get('/nyheter') do
    db = SQLite3::Database.new("db/chinook-crud.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM albums")
    p result 
    slim(:"albums/index",locals:{nyheter:result})
end

