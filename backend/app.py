from flask import Flask, render_template, request, redirect, url_for
import psycopg2
import random

app = Flask(__name__)

db_params = {
    'host': 'scrum-postgres',
    'database': 'scrumbot',
    'user': 'postgres',
    'password': 'scrumbotagent'
}
try:
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()
    print("Successfully connected to database")
except Exception as e:
    print(f"Failed to connect to database. The following error occoured: {str(e)}")


#Endpoint for signup
@app.route('/signup', methods=['POST'])
def signup():
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
        return f"Failure. The following error occured with the database: {str(e)}"
        

@app.route('/login', methods=['POST'])
def login():
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
            return f"Failure. The following error occured with the database: {str(e)}."

@app.route('/create_issue', methods=['POST'])
def create_issue():
    try:
        project_id = request.form["project_id"]
        reporter_id = request.form["reporter_id"]
        assignee_id = request.form["assignee_id"] 
        issue_title = request.form["issue_title"]
        issue_description = request.form["issue_description"]
        priority = request.form["priority"]
        story_points = 0
        id_exists = 1
        while id_exists:
            issue_id = random.randint(1000000, 9999999)
            sql_query = f"SELECT COUNT(*) FROM issue WHERE issue_id = '{issue_id}'"
            cursor.execute(sql_query)
            id_exists = cursor.fetchone()[0]
        sql_query = f"INSERT INTO issue (issue_id, project_id, issue_title, issue_description, reporter_id, assignee_id, priority, story_points) VALUES ('{issue_id}', '{project_id}', '{issue_title}', '{issue_description}', '{reporter_id}', '{assignee_id}', '{priority}', '{story_points}')"
        cursor.execute(sql_query)
        conn.commit()
        id_exists = 1
        while id_exists:
            assignment_id = random.randint(1000000, 9999999)
            sql_query = f"SELECT COUNT(*) FROM assignment where assignment_id = '{assignment_id}'"
            cursor.execute(sql_query)
            id_exists = cursor.fetchone()[0]
        assignment_query = f"INSERT INTO assignment (assignment_id, assignee_id, issue_id) VALUES ('{assignment_id}', '{assignee_id}', '{issue_id}')"
        cursor.execute(assignment_query)
        conn.commit()
        return "Success"
    except Exception as e:
        return f"Failure. The following error occured with the database: {str(e)}"
    
@app.route("/update_issue", methods=["POST"])
def create_issue():
    issue_id = str(request.form["issue_id"])
    update_fields = []
    update_values = []
    sql_query = f"SELECT * FROM ISSUES WHERE issue_id = {issue_id}"
    cursor.execute(sql_query)
    result = cursor.fetchone()[0]
    try:
        if result:
            for i in range(len(update_fields)):
                update_field = update_fields[i]
                update_value = update_values[i]
                update_query = f"UPDATE TABLE issue SET {update_field} = '{update_value}' WHERE issue_id = '{issue_id}'"
                cursor.execute(update_query)
                conn.commit()
            return "Success"
        else:
            return "Failure. The mentioned issue does not exist."
    except Exception as e:
        return f"Failure. The following error ouccured: {str(e)}"

@app.route("delete_issue", methods=["POST"])
def delete_issue():
    issue_id = str(request.form["issue_id"])
    sql_query = f"SELECT * FROM ISSUES WHERE issue_id = {issue_id}"
    cursor.execute(sql_query)
    result = cursor.fetchone()[0]
    try:
        if result:
            delete_issue = f"DELETE FROM issue WHERE issue_id = {issue_id}"
            cursor.execute(delete_issue)
            conn.commit()
            return "Success"
        else:
            return "Failed. The mentioned issue does not exist."
    except Exception as e:
        return f"Failed. The following error occured. {str(e)}"

@app.route("update_priority", methods=["POST"])
def update_priority():
    issue_id = str(request.form["issue_id"])
    priority = str(request.form["priority"])
    sql_query = f"SELECT * FROM ISSUES WHERE issue_id = {issue_id}"
    cursor.execute(sql_query)
    result = cursor.fetchone()[0]
    try:
        if result:
            update_prio = f"UPDATE TABLE issue SET priority = '{priority}' WHERE issue_id = '{issue_id}'"
            cursor.execute(update_prio)
            conn.commit()
            return "Success"
        else:
            return "Failed. The mentioned issue does not exist"
    except Exception as e:
        return f"Failed. The following error occoured: {str(e)}"

@app.route("update_story_points", methods=["POST"])
def update_story_priority():
    issue_id = str(request.form["issue_id"])
    story_points = str(request.form["story_points"])
    sql_query = f"SELECT * FROM ISSUES WHERE issue_id = {issue_id}"
    cursor.execute(sql_query)
    result = cursor.fetchone()[0]
    try:
        if result:
            update_prio = f"UPDATE TABLE issue SET story_points = '{story_points}' WHERE issue_id = '{issue_id}'"
            cursor.execute(update_prio)
            conn.commit()
            return "Success"
        else:
            return "Failed. The mentioned issue does not exist"
    except Exception as e:
        return f"Failed. The following error occoured: {str(e)}"

@app.route("scrum_update", methods = ["POST"])
def scrum_update():
    scrum_update = str(request.form["scrum_update"])
    #TODO: Process the scrum update (AI agent work).

@app.route("assign_issue", methods = ["POST"])
def assign_issue():
    try:
        issue_id = request.form["issue_id"]
        assignee_id = request.form["assignee_id"]
        issue_exists = f"SELECT count(*) FROM issue WHERE issue_id = '{issue_id}'"
        cursor.execute(issue_exists)
        result = cursor.fetchone()[0]
        if result:
            update_issue = f"UPDATE table issue set assignee_id = '{assignee_id}' where issue_id = '{issue_id}'"
            cursor.execute(update_issue)
            conn.commit()
            update_assignment = f"UPDATE table assignment set assignee_id = '{assignee_id}' where issue_id = '{issue_id}'"
            cursor.execute(update_assignment)
            conn.commit()
        else:
            return "Failed. The mentioned issue does not exist."
    except Exception as e:
        return f"Failed. The following error occured with the database. {str(e)}"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
    
