// issues_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class IssuesPage extends StatefulWidget {
  final String userId;
  final String projectId;

  IssuesPage({required this.userId, required this.projectId});

  @override
  _IssuesPageState createState() => _IssuesPageState();
}

class _IssuesPageState extends State<IssuesPage> {
  List<Map<String, dynamic>> issues = [];

  @override
  void initState() {
    super.initState();
    // Fetch issues when the widget is initialized
    fetchIssues(widget.userId, widget.projectId);
  }

  Future<void> fetchIssues(String userId, String projectId) async {
    final apiUrl = 'http://52.23.94.89:8080/my_issues';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'project_id': projectId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('status') && data['status'] == 'success') {
          setState(() {
            issues = List<Map<String, dynamic>>.from(data['value']);
          });
        } else {
          print('Failed to fetch issues. Server response: ${data['status']}');
        }
      } else {
        print('Failed to fetch issues. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchIssueDetails(int issueId) async {
    final apiUrl = 'http://52.23.94.89:8080/issue_detail';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'issue_id': issueId,
        }),
      );

      print('Fetch issue details response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('status') && data['status'] == 'success') {
          // Handle the issue details, e.g., show a popup
          _showIssueDetailsPopup(data['value']);
        } else {
          print('Failed to fetch issue details. Server response: ${data['status']}');
        }
      } else {
        print('Failed to fetch issue details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateIssue(int issueId,String userInput) async {
    final apiUrl = 'http://52.23.94.89:8080/update_issue';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'issue_id': issueId,
          'user_input': userInput,
        }),
      );
      print('Request: ${response.request}');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');


      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('status') && data['status'] == 'success') {
          // Handle the successful update, e.g., show a success message
          print('Issue updated successfully');
        } else {
          print('Failed to update issue. Server response: ${data['status']}');
        }
      } else {
        print('Failed to update issue. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to show a popup with issue details
  void _showIssueDetailsPopup(Map<String, dynamic> issueDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(issueDetails['issue_title']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${issueDetails['issue_desc']}'),
              Text('Priority: ${issueDetails['priority']}'),
              // Add more details as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the popup
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                // Show another popup for updating the issue
                _showUpdateIssuePopup(issueDetails['issue_id']);
              },
              child: Text('Update Issue'),
            ),
          ],
        );
      },
    );
  }

  // Function to show a popup for updating the issue
  void _showUpdateIssuePopup(int issueId) {
    String userInput = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Issue'),
          content: Column(
            children: [
              TextField(
                onChanged: (value) {
                  userInput = value;
                },
                decoration: InputDecoration(labelText: 'User Input'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the popup
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call the updateIssue function and close the popup
                updateIssue(issueId, userInput);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

 void _showCreateIssuePopup() {
    String userInput = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Issue'),
          content: Column(
            children: [
              TextField(
                onChanged: (value) {
                  userInput = value;
                },
                decoration: InputDecoration(labelText: 'User Input'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the popup
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call the createIssue function and close the popup
                createIssue(userInput);
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> createIssue(String userInput) async {
    final apiUrl = 'http://52.23.94.89:8080/create_issue';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reporter_id': widget.userId,
          'project_id': widget.projectId,
          'user_input': userInput,
        }),
      );

      print('Create issue response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('status') && data['status'] == 'success') {
          // Handle the successful creation, e.g., show a success message
          print('Issue created successfully');
        } else {
          print('Failed to create issue. Server response: ${data['status']}');
        }
      } else {
        print('Failed to create issue. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showScrumUpdatePopup() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path ?? '';
      String fileName = result.files.single.name;

      // Call the scrumUpdate function with the selected file path and name
      scrumUpdate(filePath, fileName);
    } else {
      // User canceled file picking
      print('User canceled file picking');
    }
  }

  Future<void> scrumUpdate(String filePath, String fileName) async {
    final apiUrl = 'http://52.23.94.89:8080/scrum_update';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'project_id': widget.projectId,
          'filename': fileName,
        }),
      );

      print('Scrum update response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('status') && data['status'] == 'success') {
          // Handle the successful scrum update, e.g., show a success message
          print('Scrum update successful');
        } else {
          print('Failed to perform scrum update. Server response: ${data['status']}');
        }
      } else {
        print('Failed to perform scrum update. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issues for Project'),
      ),
      body: ListView.builder(
        itemCount: issues.length + 2, // Add 2 for the new buttons
        itemBuilder: (context, index) {
          if (index == issues.length) {
            // Button for create_issue
            return Card(
              child: ListTile(
                title: Text('Create Issue'),
                onTap: () {
                  _showCreateIssuePopup();
                },
              ),
            );
          } else if (index == issues.length + 1) {
            // Button for scrum_update
            return Card(
              child: ListTile(
                title: Text('Scrum Update'),
                onTap: () {
                  _showScrumUpdatePopup();
                },
              ),
            );
          } else {
            // Display existing issues
            return Card(
              child: ListTile(
                title: Text(issues[index]['issue_title']),
                trailing: Text('Priority: ${issues[index]['priority']}'),
                onTap: () {
                  fetchIssueDetails(issues[index]['issue_id']);
                },
              ),
            );
          }
        },
      ),
    );
  }
}