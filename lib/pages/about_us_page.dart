import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
        ),
        title: Text(
          'About Us',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 102, 140, 84),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Title with an Icon
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green, size: 30),
                  const SizedBox(width: 8),
                  Text(
                    'About Journly',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 200,
                  decoration: BoxDecoration(
                    // color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage('assets/sp4.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Project Details:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Journly is a feature-rich journaling app that helps users document their thoughts and moments effortlessly. '
                'Built using Flutter and Firebase, it ensures a seamless experience with secure authentication and cloud storage.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  // color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Key Features:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(
                      'Secure Authentication using Firebase Auth',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(
                      '*Cloud-based storage for your journal entries',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(
                      'User-friendly interface with customization options',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(
                      '*Daily reminders to keep you consistent',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(
                      'Track your mood and analyze pattern',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(
                      'Daily affirmations to increase positivity',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Made with Ã¢ÂÂ¤Ã¯Â¸Â  by the Journly Team',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: const Color.fromARGB(136, 124, 112, 6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
