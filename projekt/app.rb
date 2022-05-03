require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:start)
end

get('/nyheter') do
    db = SQLite3::Database.new("db/chinook-crud.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM albums")
    slim(:"nyheter/index",locals:{albums:result})
end

get('/lag') do
  db = SQLite3::Database.new("db/db.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM teams")
  p result
  slim(:"lag/index",locals:{teams:result})
end

get('/lag/:id') do 
  id = params[:id].to_i
  db = SQLite3::Database.new("db/db.db")
  db.results_as_hash = true
  result = db.execute("SELECT userinfo.fullname FROM teams
  INNER JOIN userinfo ON teams.teamName = userinfo.team
  WHERE teamID =?",id)
  p result
  slim(:"lag/show",locals:{players:result})
end

get('/kontakt') do
    db = SQLite3::Database.new("db/db.db")
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

get('/register') do
  slim(:register)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    p result
    if result == nil
      redirect('/error')
    end
    pwdigest = result["password_digest"]
    id = result["userID"]
  
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
      db = SQLite3::Database.new('db/db.db')
      db.execute('INSERT INTO users (username,password_digest) VALUES (?,?)',username,password_digest)
      db.execute('INSERT INTO userinfo (username) VALUES (?)',username)
      redirect('/showlogin')
    else
      #felhantering
      "lösenorden matchar inte"
    end
end

get('/documenttingz') do
  db = SQLite3::Database.new("db/db.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM documents")
  slim(:"documenttingz/index",locals:{documents:result})
end

get('/documenttingz/new') do
  db = SQLite3::Database.new("db/db.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM documents")
  slim(:"documenttingz/new",locals:{documents:result})
end

post('/documenttingz/new') do
  docTitle = params[:docTitle]
  docLink = params[:docLink]
  db = SQLite3::Database.new("db/db.db")
  db.execute("INSERT INTO documents (docTitle, docLink) VALUES (?,?)", docTitle, docLink)
  redirect('/documenttingz')
end

post('/documenttingz/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/db.db")
  db.execute("DELETE FROM documents WHERE DocId = ?",id)
  redirect('/documenttingz')
end

get('/profil') do
  db = SQLite3::Database.new("db/db.db")
  db.results_as_hash = true
  #result = db.execute("SELECT username FROM users WHERE userID= ?",session[:id]).first
  result = db.execute("SELECT * FROM userinfo WHERE userID= ?",session[:id]).first
  slim(:"profil/index",locals:{userinfo:result})
end

get('/profil/edit') do
  db = SQLite3::Database.new("db/db.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM userinfo WHERE userID= ?",session[:id]).first
  slim(:"profil/edit",locals:{userinfo:result})
end

post('/profil/edit') do
  fullname = params[:fullname]
  age = params[:age]
  team = params[:team]
  db = SQLite3::Database.new("db/db.db")
  db.results_as_hash = true
  #db.execute("INSERT INTO userinfo (fullname, age, team) VALUES (?,?,?)", fullname, age, team)
  db.execute("UPDATE userinfo SET fullname=?,age=?,team=? WHERE userID = ?",fullname,age,team,session[:id])
  redirect('/profil')
end

