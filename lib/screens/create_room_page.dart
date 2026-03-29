import 'package:flutter/material.dart';
import 'package:skribbl_clone/screens/doodle_page.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  late String? _maxRoundsValue;
  late String? _roomSizeValue;

  void createRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty &&
        _maxRoundsValue != null &&
        _roomSizeValue != null) {
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text,
        "occupancy": _maxRoundsValue!,
        "maxRounds": _roomSizeValue!,
      };
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              DoodlePage(data: data, screenFrom: 'createRoom'),
        ),
      );
    }
  }

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
                              controller: _nameController,
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
                              controller: _roomNameController,
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
                                            items: ["2", "4", "6"]
                                                .map(
                                                  (item) =>
                                                      DropdownMenuItem<String>(
                                                        value: item,
                                                        child: Text(item),
                                                      ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              _maxRoundsValue = value;
                                            },
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
                                            items: ["1", "2", "3", "4", "5"]
                                                .map(
                                                  (item) =>
                                                      DropdownMenuItem<String>(
                                                        value: item,
                                                        child: Text(item),
                                                      ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              _roomSizeValue = value;
                                            },
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
                                              items: ["2", "4", "6"]
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
                                              onChanged: (value) {
                                                _maxRoundsValue = value;
                                              },
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
                                              items: ["2", "3", "4", "5", "6"]
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
                                              onChanged: (value) {
                                                _roomSizeValue = value;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                            const SizedBox(height: 15),

                            ElevatedButton(
                              onPressed: createRoom,
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
