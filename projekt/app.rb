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
    slim(:"nyheter/index",locasl:{news:result})
end

get('/lag') do
  db = SQLite3::Database.new("db/kontakter.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM teams")
  slim(:"lag",locals:{teams:result})
end

get('/kontakt') do
    db = SQLite3::Database.new("db/kontakter.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM employees")
    slim(:"contact",locals:{employees:result})
end

get('/showlogin') do
    slim(:login)
end

get('/calender') do
    slim(:calender)
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
    db = SQLite3::Database.new('db/kontakter.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    if result.empty?
      redirect('/error')
    end
    pwdigest = result["pwdigest"]
    id = result["id"]
  
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/')
    else
      "FEL LÖSENORD!"
    end
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if (password == password_confirm)
      #lägg till användare
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/kontakter.db')
      db.execute('INSERT INTO users (username,password_digest) VALUES (?,?)',username,password_digest)
      redirect('/')
    else
      #felhantering
      "lösenordet är fel"
    end
end

get('/documenttingz') do
  db = SQLite3::Database.new("db/kontakter.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM documents")
  slim(:"documenttingz/index",locals:{documents:result})
end

get('/documenttingz/new') do
  db = SQLite3::Database.new("db/kontakter.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM documents")
  slim(:"documenttingz/new",locals:{documents:result})
end

post('/documenttingz/new') do
  docTitle = params[:docTitle]
  docLink = params[:docLink]
  db = SQLite3::Database.new("db/kontakter.db")
  db.execute("INSERT INTO documents (docTitle, docLink) VALUES (?,?)", docTitle, docLink)
  redirect('/documenttingz')
end

post('/documenttingz/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/kontakter.db")
  db.execute("DELETE FROM documents WHERE DocId = ?",id)
  redirect('/documenttingz')
end