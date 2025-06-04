import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;

          if (args == null ||
              args['nextRoute'] == null ||
              args['transactionData'] == null) {
            print("Error: Missing arguments for LoadingScreen.");
            // Optionally navigate back or show an error message
            // Navigator.pop(context); // Example
            return;
          }

          final nextRoute = args['nextRoute'] as String;
          final transactionData =
              args['transactionData'] as Map<String, dynamic>;

          // Using Duration(seconds: 3) instead of 3000 for faster testing
          // Change back to 3000 if that was intentional (though it seems very long)
          Future.delayed(const Duration(seconds: 3), () {
            // Adjusted duration
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                nextRoute,
                arguments: transactionData,
              );
            }
          });
        } catch (e) {
          print("Error retrieving arguments: $e");
          // Handle error appropriately, maybe pop the screen
          // if (mounted) Navigator.pop(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep the icon definition as is
    Widget iconWithBackground = Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width:
              50.0, // Consider making the container slightly larger than the icon
          height: 50.0,
          decoration: const BoxDecoration(
            color: Colors.green, // Changed to green as per original icon bg
            shape: BoxShape.circle,
          ),
        ),
        // Make Icon slightly smaller than container to fit inside circle properly
        const Icon(
          Icons.access_time,
          color: Colors.white,
          size: 80.0,
        ), // Adjusted size
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          // Keep the overall horizontal padding
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            // Use Column for vertical arrangement
            children: <Widget>[
              // --- Top/Middle Content ---
              const SizedBox(height: 60), // Spacing from top
              iconWithBackground, // Your icon widget
              const SizedBox(height: 20), // Spacing below icon
              const Text(
                'Processing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal, // Changed from bold
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20), // Optional spacing before divider
              const Divider(color: Colors.grey, thickness: 0.5), // Divider
              // --- Spacer to push button down ---
              const Spacer(), // This takes up all remaining space
              // --- Bottom Content (The Button) ---
              SizedBox(
                // Keep SizedBox for width control
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC83D),
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.0),
                    ),
                  ),
                  onPressed: () {
                    // Implement button action if needed,
                    // though the screen auto-navigates currently.
                    // Maybe cancel the timer and navigate immediately?
                    print("Finished button pressed");
                  },
                  child: const Text(
                    'Finished',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              // Add some padding below the button so it's not flush with the bottom
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}
