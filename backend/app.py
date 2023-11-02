from flask import Flask, render_template, request, redirect, url_for
import psycopg2
import random

app = Flask(__name__)

db_params = {
    'host': 'scrum-bot.coheqcprynnh.us-east-1.rds.amazonaws.com',
    'database': 'scrum_bot',
    'user': 'postgres',
    'password': 'scrum-bot123'
}
try:
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()
except Exception as e:
    print(f"Failed to connect to RDS Instance. The following error occoured: {str(e)}")


#Endpoint for signup
@app.route('/signup', methods=['POST'])
def login():
    firstname = str(request.form['first_name'])
    lastname = str(request.form['last_name'])
    email = str(request.form['email'])
    phone = str(request.form['phone'])
    password = str(request.form['password'])
    dob = str(request.form['dob'])
    result = 1
    while result != 0:
        userid = random.randint(1000000, 9999999)
        check_userid = f"SELECT COUNT(*) FROM users where user_id = '{userid}'"
        cursor.execute(check_userid)
        result = cursor.fetchone()[0]
    try:
        sql_query = "SELECT COUNT(*) FROM users WHERE email = %s"
        cursor.execute(sql_query, (email,))
        result = cursor.fetchone()[0]
        if result == 0:
            add_user_query = f"INSERT INTO users (user_id, first_name, last_name, email, phone, dob) VALUES ('{userid}', '{firstname}', '{lastname}', '{email}', '{phone}', '{dob}')"
            cursor.execute(add_user_query)
            user_login_query = f"INSERT INTO user_login (user_id, email, password) VALUES ('{userid}', '{email}', '{password}')"
            cursor.execute(user_login_query)
            conn.commit()
            return "Success"
        else:
            return "Failure. User already Exists."
    except Exception as e:
        return f"Failure. The following error occured: {str(e)}"
        

@app.route('/login', methods=['POST'])
def signup():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        try:
            sql_query = "SELECT COUNT(*) FROM user_login WHERE email = %s and password = %s"
            cursor.execute(sql_query, (email, password,))
            result = cursor.fetchone()[0]
            if result != 0:
                return "Success"
            else:
                return "Failure. User does not exist."
        except Exception as e:
            return f"Failure. The following error occured: {str(e)}."

if __name__ == '__main__':
    app.run(debug=True)
