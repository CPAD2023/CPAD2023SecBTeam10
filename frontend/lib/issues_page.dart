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
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Call the updateIssue function and close the popup
                    await updateIssue(issueId, userInput);
                    Navigator.of(context).pop();
                    // Refresh issues after the update
                    fetchIssues(widget.userId, widget.projectId);
                  },
                  child: Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Call the deleteIssue function and close the popup
                    await deleteIssue(issueId);
                    Navigator.of(context).pop();
                    // Refresh issues after the deletion
                    fetchIssues(widget.userId, widget.projectId);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Button color for delete
                  ),
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
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
            onPressed: () async {
              // Call the createIssue function and close the popup
              await createIssue(userInput);
              Navigator.of(context).pop();
              // Refresh issues after creating a new issue
              fetchIssues(widget.userId, widget.projectId);
            },
            child: Text('Create'),
          ),
        ],
      );
    },
  );
}


  Future<void> deleteIssue(int issueId) async {
    final apiUrl = 'http://52.23.94.89:8080/delete_issue';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'issue_id': issueId,
        }),
      );

      print('Delete issue response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('status') && data['status'] == 'success') {
          // Handle the successful deletion, e.g., show a success message
          _showSnackBar('Issue deleted successfully', Colors.green);
        } else {
          print('Failed to delete issue. Server response: ${data['status']}');
          _showSnackBar('Failed to delete issue. Please try again.', Colors.red);
        }
      } else {
        print('Failed to delete issue. Status code: ${response.statusCode}');
        _showSnackBar('Failed to delete issue. Please try again.', Colors.red);
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('An error occurred. Please try again.', Colors.red);
    }
  }

  // Function to show a SnackBar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
      ),
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

Future<void> scrumUpdate(String fileName) async {
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

  void _showScrumUpdatePopup() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    
    String fileName = result.files.single.name;

    // Call the scrumUpdate function with the selected file path and name
    await scrumUpdate(fileName);

    // Show a popup indicating successful scrum update
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scrum Update Successful'),
          content: Text('Scrum update has been successfully performed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  } else {
    // User canceled file picking
    print('User canceled file picking');
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
              child: ElevatedButton(
                onPressed: () {
                  _showCreateIssuePopup();
                },
                child: Text('Create Issue'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurpleAccent, // Button color
                  onPrimary: Colors.white, // Text color
                ),
              ),
            );
          } else if (index == issues.length + 1) {
            // Button for scrum_update
            return Card(
              child: ElevatedButton(
                onPressed: () {
                  _showScrumUpdatePopup();
                },
                child: Text('Scrum Update'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurpleAccent, // Button color
                  onPrimary: Colors.white, // Text color
                ),
              ),
            );
          } else {
            // Display existing issues
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.grey), // Border color for each card
              ),
              margin: EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  fetchIssueDetails(issues[index]['issue_id']);
                },
                child: ListTile(
                  title: Text(issues[index]['issue_title']),
                  subtitle: Text('Priority: ${issues[index]['priority']}'),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}