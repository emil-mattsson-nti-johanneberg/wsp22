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

get('/kontakt') do
    slim(:contact)
end

get('/showlogin') do
    slim(:login)
end

get('/profile') do
    slim(:profile)
end

get('/register') do
  slim(:register)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    if result.empty?
      redirect('/error')
    end
    pwdigest = result["pwdigest"]
    id = result["id"]
  
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/documents')
    else
      "FEL LÖSENORD!"
    end
end


get('/documents') do
    slim(:documents)
end



post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if (password == password_confirm)
      #lägg till användare
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/todo2021-db')
      db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',username,password_digest)
      redirect('/')
    else
      #felhantering
      "lösenordet är fel"
    end
end

get('/documenttingz/new') do
  slim(:"documenttingz/new")
end