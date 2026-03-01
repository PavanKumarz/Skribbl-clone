import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),

          Container(color: Colors.blue.withOpacity(0.2)),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            "MULTIPLAYER DRAWING GAME",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Sketch fast.Guess faster.",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          "Create a private room or join friends instantly",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.yellow[300],
                          ),
                        ),

                        const SizedBox(height: 30),

                        isMobile
                            ? Column(
                                children: [
                                  _buildCard(context, true),
                                  const SizedBox(height: 20),
                                  _buildCard(context, false),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: _buildCard(context, true)),
                                  const SizedBox(width: 20),
                                  Expanded(child: _buildCard(context, false)),
                                ],
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, bool isCreate) {
    final cardColor = isCreate ? Colors.blue[200] : Colors.green[200];
    final title = isCreate ? "Create Room" : "Join Room";
    final buttonText = isCreate ? "Create" : "Join";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Host a game and invite players"),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
