from flask import Flask, render_template, request, redirect, url_for, jsonify
from agents.agent import AgentInstance
import psycopg2
import random
import os
import json
import requests
from flask_cors import CORS

def find_changed_attributes(old_dict, new_dict):
    changed_attributes = {}

    for key, new_value in new_dict.items():
        old_value = old_dict.get(key, None)

        if old_value is not None and old_value != new_value:
            changed_attributes[key] = (new_value)

    return changed_attributes

DIR = os.path.abspath(os.path.dirname(__file__))
app = Flask(__name__)
CORS(app)

db_params = {
    'host': 'autoscrum.coheqcprynnh.us-east-1.rds.amazonaws.com',
    'database': 'scrum-agent',
    'user': 'postgres',
    'password': 'postgres'
}
try:
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()
    print("Successfully connected to database")
except Exception as e:
    print(f"Failed to connect to database. The following error occoured: {str(e)}")


#test endpoint
@app.route('/hi', methods=['GET'])
def say_hi():
    return "hi"

#Endpoint for signup
@app.route('/signup', methods=['POST'])
def signup():
    payload = request.json
    firstname = payload.get("first_name")
    lastname = payload.get("last_name")
    email = payload.get("email")
    phone = payload.get("phone")
    password = payload.get("password")
    dob = payload.get("dob")
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
            return jsonify({'status': 'success', 'value': str(userid)})
        else:
            return jsonify({'status': 'failure', 'value': 'User already exists'})
    except psycopg2.Error as e:
            conn.rollback()
    except Exception as e:
        return jsonify({'status': 'failure', 'value': str(e)})
    

@app.route('/login', methods=['POST'])
def login():
    if request.method == 'POST':
        payload = request.json
        email = payload.get('email')
        password = payload.get('password')

        try:
            sql_query = "SELECT COUNT(*) FROM user_login WHERE email = %s and password = %s"
            cursor.execute(sql_query, (email, password,))
            result = cursor.fetchone()[0]
            if result != 0:
                sql_query = "SELECT user_id FROM user_login WHERE email = %s and password = %s"
                cursor.execute(sql_query, (email, password,))
                user_id = cursor.fetchone()[0]
                return jsonify({'status': 'success', 'value':str(user_id)})
            else:
                return jsonify({'status':'failure', 'value':'User not found'})
        except psycopg2.Error as e:
            conn.rollback()
        except Exception as e:
            return jsonify({'status':'failure', 'value': str(e)})
        
        
@app.route("/my_projects", methods=["POST"])
def my_project():
    try:
        payload = request.json
        userid = payload.get('user_id')
        query = """
                SELECT DISTINCT p.project_id
                FROM projects p
                JOIN issue i ON p.project_id = i.project_id
                JOIN assignment a ON i.issue_id = a.issue_id
                WHERE a.assignee_id = %s;
            """
        cursor.execute(query, (userid,))
        project_ids = [result[0] for result in cursor.fetchall()]
        return jsonify({'status': 'success', 'value':project_ids})
    except psycopg2.Error as e:
        conn.rollback()
    except Exception as e:
        return jsonify({'status': 'failure', 'value':str(e)})
    

@app.route("/my_issues", methods=["POST"])
def my_issues():
    try:
        payload = request.json
        userid = payload.get('user_id')
        projectid = payload.get('project_id')
        query = """
                SELECT
                    i.issue_id,
                    i.issue_title,
                    i.issue_desc,
                    i.story_points,
                    i.priority,
                    u.first_name || ' ' || u.last_name AS assigned_user
                FROM
                    issue i
                JOIN
                    users u ON i.assignee_id = u.user_id
                WHERE
                    i.project_id = %s
                    AND i.assignee_id = %s;
        """
        cursor.execute(query, (projectid, userid))
        columns = [desc[0] for desc in cursor.description]
        issues = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return jsonify({'status': 'success', 'value': issues})
    except psycopg2.Error as e:
        conn.rollback()
    except Exception as e:
        return jsonify({'status': 'failure', 'value': str(e)})
    

@app.route('/issue_detail', methods=['POST'])
def issue_detail():
    try:
        payload = request.json
        issue_id = payload.get('issue_id')
        query = """
            SELECT
                i.issue_id,
                i.issue_title,
                i.issue_desc,
                i.reporter_id,
                i.assignee_id,
                i.priority,
                i.story_points
            FROM
                issue i
            WHERE
                i.issue_id = %s;
        """
        cursor.execute(query, (issue_id,))
        columns = [desc[0] for desc in cursor.description]
        issue_details = dict(zip(columns, cursor.fetchone()))
        return jsonify({'status': 'success', 'value':issue_details})
    except psycopg2.Error as e:
        conn.rollback()
    except Exception as e:
        return jsonify({"status":'failure', 'value':str(e)})
    
    
@app.route('/get_all_issues', methods=['POST'])
def get_all_issues():
    try:
        payload = request.json
        project_id = payload.get('project_id')
        query = f"SELECT issue_id, issue_title, issue_desc FROM issue WHERE project_id = {project_id}"
        cursor.execute(query)
        issues_data = cursor.fetchall()
        issues_list = [{'issue_id': row[0], 'issue_title': row[1], 'issue_desc': row[2]} for row in issues_data]
        return jsonify({'status': 'success', 'value':issues_list})
    except Exception as e:
        return jsonify({'status': 'failure', 'value':str(e)})

@app.route('/create_project', methods=['POST'])
def create_project():
    try:
        payload = request.json
        project_title = payload.get('project_title')
        project_desc = payload.get('project_desc')
        id_exists = 1
        while id_exists:
            project_id = str(random.randint(1000000, 9999999))
            id_exists_query = f"SELECT COUNT(*) FROM projects WHERE project_id = '{project_id}'"
            cursor.execute(id_exists_query)
            id_exists = cursor.fetchone()[0]
        create_project_quert =f"INSERT INTO projects (project_id, project_title, project_desc) values ('{project_id}', '{project_title}', '{project_desc}')"
        cursor.execute(create_project_quert)
        conn.commit()
        return jsonify({'status': 'success', 'value':str(project_id)})
    except psycopg2.Error as e:
        conn.rollback()
    except Exception as e:
        return jsonify({'status':'failure', 'value':str(e)}) 

@app.route('/create_issue', methods=['POST'])
def create_issue():
    try:
        payload = request.json
        reporter = payload.get("reporter_id")
        project_id = payload.get("project_id")
        user_input = f"The reporter {reporter} has asked for the creation of a new issue for the project {project_id} with the following details: "+payload.get("user_input")
        agent_instance = AgentInstance(action="create_issue")
        with open(os.path.join(DIR, 'agents', 'prompt', 'create_issue.txt'), 'r') as f:
            lines = f.readlines()
            task = "\n".join(lines)
        f.close()
        project_query = """SELECT project_title FROM projects WHERE project_id = %s;"""
        cursor.execute(project_query, (project_id,))
        project_name = cursor.fetchone()[0]
        project_name = "_".join(project_name.lower().split(' '))
        with open(os.path.join(DIR,'assets', 'projects', project_name+'.txt'), 'r') as f:
            lines = f.readlines()
            context = "\n".join(lines)
        agent_respose = agent_instance.ask_gpt(context=context, task=task, user_input=user_input)
        agent_respose = json.loads(agent_respose)

        reporter_id = agent_respose["reporter_id"]
        assignee_id = agent_respose["assignee_id"] 
        issue_title = agent_respose["issue_title"]
        issue_description = agent_respose["issue_description"].replace("\'", "")
        priority = agent_respose["priority"]
        story_points = agent_respose["story_points"]
        id_exists = 1
        while id_exists:
            issue_id = random.randint(1000000, 9999999)
            sql_query = f"SELECT COUNT(*) FROM issue WHERE issue_id = '{issue_id}'"
            cursor.execute(sql_query)
            id_exists = cursor.fetchone()[0]
        sql_query = f"INSERT INTO issue (issue_id, project_id, issue_title, issue_desc, reporter_id, assignee_id, priority, story_points) VALUES ('{issue_id}', '{project_id}', '{issue_title}', '{issue_description}', '{reporter_id}', '{assignee_id}', '{priority}', '{story_points}')"
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
        return jsonify({'status': 'success', 'value':str(issue_id)})
    except psycopg2.Error as e:
        conn.rollback()
    except Exception as e:
        return jsonify({'status': 'failure', 'value':str(e)})
    
@app.route("/update_issue", methods=["POST"])
def update_issue():
    payload = request.json
    issue_id = payload.get("issue_id")
    user_input = payload.get("user_input")
    data = {'issue_id': issue_id}
    headers = {'Content-Type': 'application/json'}
    current_issue = requests.post(url='http://localhost:8080/issue_detail', json=data, headers=headers).json()
    issue_details_string = current_issue
    sql_query = f"SELECT * FROM issue WHERE issue_id = {issue_id}"
    cursor.execute(sql_query)
    result = cursor.fetchone()[0]
    try:
        if result:
            context = f"The current state of the issue is as follows: {issue_details_string}"
            with open(os.path.join(DIR, 'agents', 'prompt', 'update_issue.txt'), 'r') as f:
                lines = f.readlines()
                task = "\n".join(lines)
                task = "You need to update the details of the issue and return a updated json. {task}"
            f.close()
            agent_instance = AgentInstance(action="update_issue")
            agent_respose = agent_instance.ask_gpt(context=context, task=task, user_input=user_input)
            updated_issue = json.loads(agent_respose)
            changes = find_changed_attributes(old_dict=current_issue, new_dict=updated_issue)
            for changed_atrribute in changes.keys():
                attrbute = changed_atrribute
                value = changes[changed_atrribute]
                value = str(value).replace("'", "")
                udpate_query =f"UPDATE issue SET {attrbute} = '{value}' WHERE issue_id = '{issue_id}'"
                cursor.execute(udpate_query)
                conn.commit()
                if attrbute == "assignee_id":
                    change_assignment = f"update assignment set assignee_id = '{value}' where issue_id = '{issue_id}'"
                    cursor.execute(change_assignment)
                    conn.commit()
            return jsonify({'status': 'success', 'value':str(issue_id)})
        else:
            return jsonify({'status': 'failure', 'value':'issue not found'})
    except Exception as e:
        return jsonify({'status': 'failure', 'value':str(e)})

@app.route("/delete_issue", methods=["POST"])
def delete_issue():
    payload = request.json
    issue_id = payload.get('issue_id')
    sql_query = f"SELECT * FROM issue WHERE issue_id = {issue_id}"
    cursor.execute(sql_query)
    result = cursor.fetchone()[0]
    try:
        if result:
            delete_assignment = f"DELETE FROM assignment where issue_id = {issue_id}"
            cursor.execute(delete_assignment)
            conn.commit()
            delete_issue = f"DELETE FROM issue WHERE issue_id = {issue_id}"
            cursor.execute(delete_issue)
            conn.commit()
            return jsonify({'status': 'success', 'value':str(issue_id)})
        else:
            return jsonify({'status': 'failure', 'value':'issue not found'})
    except psycopg2.Error as e:
        conn.rollback()
    except Exception as e:
        return jsonify({'status': 'failure', 'value':str(e)})

@app.route("/scrum_update", methods = ["POST"])
def scrum_update():
    try:
        payload = request.json
        project_id = payload.get("project_id")
        filename = payload.get("filename")
        filepath = os.path.join(DIR, 'assets', 'updates', filename)
        with open(filepath, 'r') as f:
            lines = f.readlines()
            scrum_content = "\n".join(lines)
        f.close()
        context = scrum_content
        with open(os.path.join(DIR, 'agents', 'prompt', 'process_scrum_content.txt'), 'r') as f:
                    lines = f.readlines()
                    task = "\n".join(lines)
                    task = f"You need to process the scum update that was discussed by the team. {task}"
        f.close()
        agent = AgentInstance(action="process_scrum_update")
        agent_response = agent.ask_gpt(context = context, task=task, user_input = "Process the provided scrum update")
        json_data = json.loads(agent_response)
        all_tasks = list(json_data)
        responses = []
        for task in all_tasks:
            current_task = task.get("task")
            if current_task == "create_issue":
                reporter_id = task.get("reporter_id")
                task_description = task.get("task_description")
                data = {"reporter_id": reporter_id, "project_id": project_id, "user_input": task_description}
                headers = {'Content-Type': 'application/json'}
                response = requests.post('http://localhost:8080/create_issue', json=data, headers=headers)
                responses.append(response.text)
            elif current_task == "update_issue":
                issue_id = task.get("issue_id")
                task_description = task.get("task_description")
                data = {"issue_id": issue_id, "user_input": task_description}
                headers = {'Content-Type': 'application/json'}
                response = requests.post('http://localhost:8080/update_issue', json=data, headers=headers)
                responses.append(response.text)
        return jsonify({'status': 'success', 'value':filename})
    except psycopg2.Error as e:
        conn.rollback()
    except Exception as e:
        return jsonify({'status': 'failure', 'value':str(e)})

if __name__ == '__main__':
    app.run(debug=True, port=8080, host='0.0.0.0')
    
