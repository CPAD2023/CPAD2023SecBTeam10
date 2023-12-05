
-- Connect to the scrum-bot database
\c scrum_bot;

-- Create the users table
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(15),
    dob DATE
);

-- Create the user_login table with foreign key constraint
CREATE TABLE user_login (
    user_id INT PRIMARY KEY REFERENCES users(user_id),
    email VARCHAR(255),
    password VARCHAR(255)
);

-- Create the projects table
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_title VARCHAR(255),
    project_desc TEXT
);

-- Create the issue table with foreign key constraints
CREATE TABLE issue (
    issue_id INT PRIMARY KEY,
    project_id INT REFERENCES projects(project_id),
    reporter_id INT REFERENCES users(user_id),
    assignee_id INT REFERENCES users(user_id),
    issue_title VARCHAR(255),
    issue_desc TEXT,
    priority VARCHAR(50),
    story_points INT,
    done_criteria TEXT
);

-- Create the assignment table with foreign key constraints
CREATE TABLE assignment (
    assignment_id INT PRIMARY KEY,
    issue_id INT REFERENCES issue(issue_id),
    assignee_id INT REFERENCES users(user_id)
);

