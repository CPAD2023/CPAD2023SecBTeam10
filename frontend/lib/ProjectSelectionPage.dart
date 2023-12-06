import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';

class ProjectSelectionPage extends StatefulWidget {
  final String userId;

  ProjectSelectionPage({required this.userId});

  @override
  _ProjectSelectionPageState createState() => _ProjectSelectionPageState();
}

class _ProjectSelectionPageState extends State<ProjectSelectionPage> {
  String? selectedProject;
  List<String> projects = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Selection'),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Select a Project:'),
                  SizedBox(height: 16.0),
                  DropdownButton<String>(
                    value: selectedProject,
                    items: projects
                        .map((project) =>
                        DropdownMenuItem(value: project, child: Text(project)))
                        .toList(),
                    onChanged: (selectedItem) {
                      setState(() {
                        selectedProject = selectedItem;
                      });

                      // Handle the selected project
                      print('Selected Project: $selectedProject');
                    },
                    hint: Text('Select Project'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
