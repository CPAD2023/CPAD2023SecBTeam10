import 'package:flutter/material.dart';

class ProjectSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Select a Project:'),
            SizedBox(height: 16.0),
            // Dropdown menu to select various projects
            DropdownButton<String>(
              items: [
                DropdownMenuItem(value: 'Project A', child: Text('Project A')),
                DropdownMenuItem(value: 'Project B', child: Text('Project B')),
                // Add more projects as needed
              ],
              onChanged: (selectedProject) {
                // Handle the selected project
                print('Selected Project: $selectedProject');
              },
              hint: Text('Select Project'),
            ),
          ],
        ),
      ),
    );
  }
}
