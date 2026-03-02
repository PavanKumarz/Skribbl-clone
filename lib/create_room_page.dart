import 'package:flutter/material.dart';

class CreateRoomPage extends StatelessWidget {
  const CreateRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Create Room", style: TextStyle(color: Colors.amber)),
        iconTheme: IconThemeData(color: Colors.white, size: 40),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),

              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;

                  return SingleChildScrollView(
                    child: Container(
                      width: isMobile ? double.infinity : 400,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Host a new game",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Set room details and invite your friends.",
                            ),
                            const SizedBox(height: 5),

                            // Nickname
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Your nickname',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                isDense: true,
                                prefixIcon: const Icon(Icons.person_outline),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Room name
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Room name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                isDense: true,
                                prefixIcon: const Icon(Icons.house_outlined),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            isMobile
                                ? Column(
                                    children: [
                                      InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Max rounds',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            hint: const Text('Select'),
                                            items: ["4", "6", "8"]
                                                .map(
                                                  (item) =>
                                                      DropdownMenuItem<String>(
                                                        value: item,
                                                        child: Text(item),
                                                      ),
                                                )
                                                .toList(),
                                            onChanged: (value) {},
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Room size',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            hint: const Text('Select'),
                                            items: ["3", "5", "7"]
                                                .map(
                                                  (item) =>
                                                      DropdownMenuItem<String>(
                                                        value: item,
                                                        child: Text(item),
                                                      ),
                                                )
                                                .toList(),
                                            onChanged: (value) {},
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                // DESKTOP → SIDE BY SIDE
                                : Row(
                                    children: [
                                      Expanded(
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                            labelText: 'Max rounds',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              hint: const Text('Select'),
                                              items: ["4", "6", "8"]
                                                  .map(
                                                    (item) =>
                                                        DropdownMenuItem<
                                                          String
                                                        >(
                                                          value: item,
                                                          child: Text(item),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged: (value) {},
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                            labelText: 'Room size',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              hint: const Text('Select'),
                                              items: ["3", "5", "7"]
                                                  .map(
                                                    (item) =>
                                                        DropdownMenuItem<
                                                          String
                                                        >(
                                                          value: item,
                                                          child: Text(item),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged: (value) {},
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                            const SizedBox(height: 15),

                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 45),
                              ),
                              child: const Text('Create & start'),
                            ),
                          ],
                        ),
                      ),
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
}
