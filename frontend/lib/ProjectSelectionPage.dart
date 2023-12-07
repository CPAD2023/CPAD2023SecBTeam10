import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'issues_page.dart'; // Import the IssuesPage

class ProjectSelectionPage extends StatefulWidget {
  final String userId;

  ProjectSelectionPage({required this.userId});

  @override
  _ProjectSelectionPageState createState() => _ProjectSelectionPageState();
}

class _ProjectSelectionPageState extends State<ProjectSelectionPage> {
  String? selectedProject;
  List<String> projects = [];

  TextEditingController _newProjectController = TextEditingController();
  TextEditingController _newProjectDescriptionController = TextEditingController();

  // Function to perform logout and navigate to login page
  void _logout() {
    // Add any necessary logout logic here

    // Navigate to the login page
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    // Fetch projects when the widget is initialized
    fetchProjects(widget.userId);
  }

  Future<void> fetchProjects(String userId) async {
    final apiUrl = 'http://52.23.94.89:8080/my_projects';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('status') && data['status'] == 'success') {
          List<dynamic> projectIds = data['value'];

          setState(() {
            projects = projectIds.map((projectId) => projectId.toString()).toList();
          });
        } else {
          print('Failed to fetch projects. Server response: ${data['status']}');
        }
      } else {
        print('Failed to fetch projects. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> createProject(String projectName, String projectDescription) async {
    final apiUrl = 'http://52.23.94.89:8080/create_project';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'project_name': projectName,
          'project_description': projectDescription,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('status') && data['status'] == 'success') {
          // Refresh the project list after creating a new project
          fetchProjects(widget.userId);
        } else {
          print('Failed to create project. Server response: ${data['status']}');
        }
      } else {
        print('Failed to create project. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _showCreateProjectDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Project'),
          content: Column(
            children: [
              TextField(
                controller: _newProjectController,
                decoration: InputDecoration(hintText: 'Enter Project Name'),
              ),
              TextField(
                controller: _newProjectDescriptionController,
                decoration: InputDecoration(hintText: 'Enter Project Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String projectName = _newProjectController.text;
                String projectDescription = _newProjectDescriptionController.text;
                createProject(projectName, projectDescription);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Selection'),
        backgroundColor: Color.fromRGBO(143, 148, 251, 1),
        actions: [
          // Logout button
          TextButton(
            onPressed: _logout,
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: FadeInUp(
                        duration: Duration(seconds: 1),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/light-1.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: FadeInUp(
                        duration: Duration(milliseconds: 1200),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/light-2.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      child: FadeInUp(
                        duration: Duration(milliseconds: 1600),
                        child: Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              "Project Selection",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Select a Project:'),
                  SizedBox(height: 16.0), // Added spacing between the button and dropdown

                  Container(
                    width: 150.0, // Set your desired width
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0), // Make it more rounded
                      border: Border.all(color: Colors.deepPurpleAccent, width: 2.0),
                    ),
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: selectedProject,
                          items: projects
                              .map((project) => DropdownMenuItem(value: project, child: Text(project)))
                              .toList(),
                          onChanged: (selectedItem) {
                            setState(() {
                              selectedProject = selectedItem;
                            });

                            // Navigate to the IssuesPage with the selected project and user IDs
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IssuesPage(
                                  userId: widget.userId,
                                  projectId: selectedProject!,
                                ),
                              ),
                            );
                          },
                          hint: Text('Select Project'),
                          style: TextStyle(
                            color: Colors.deepPurpleAccent, // Text color
                            fontSize: 16.0, // Text size
                          ),
                          underline: Container(), // Remove the default underline
                          alignment: Alignment.center, // Center align the text
                        ),
                        // Icon(
                        //   Icons.arrow_drop_down,
                        //   color: Colors.deepPurpleAccent, // Dropdown arrow color
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showCreateProjectDialog(context),
                child: Text('Create New Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
