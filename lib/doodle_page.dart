import 'package:flutter/material.dart';
import 'package:skribbl_clone/waiting_room_page.dart';
import 'package:skribbl_clone/widgets/toolbar.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DoodlePage extends StatefulWidget {
  final Map data;
  final String screenFrom;

  const DoodlePage({super.key, required this.data, required this.screenFrom});

  @override
  State<DoodlePage> createState() => _DoodlePageState();
}

class _DoodlePageState extends State<DoodlePage> {
  late IO.Socket _socket;

  List<Widget> textBlankWidget = [];
  final ScrollController _scrollController = ScrollController();
  List<Map> messages = [];
  TextEditingController controller = TextEditingController();

  Map dataOfRoom = {};

  @override
  void initState() {
    super.initState();
    connect();
    print(widget.data);
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(
        Text(
          '_ ',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  void connect() {
    _socket = IO.io('http://10.72.235.73:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoconnect': false,
    });

    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    _socket.onConnect((data) {
      print('Connected !');

      _socket.on('updatedRoom', (roomData) {
        print(roomData['word']);
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });

        if (roomData['isJoin'] != true) {}
      });

      _socket.on('msg', (msgData) {
        print("RAW MESSAGE RECEIVED: $msgData (${msgData.runtimeType})");

        setState(() {
          messages.add(msgData);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });

      _socket.on('notCorrectGame', (msg) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 800;

            return dataOfRoom['isJoin'] == true
                ? WaitingRoomPage(
                    lobbyName: dataOfRoom['name'],
                    noOfPlayers: dataOfRoom['players'].length,
                    occupancy: dataOfRoom['occupancy'],
                    players: dataOfRoom['players'],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),

                      isMobile
                          ? Column(
                              children: [
                                Expanded(child: buildCanvasSection()),
                                SizedBox(height: 5),
                                SizedBox(
                                  height: 300,
                                  child: buildChatSection(),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: buildCanvasSection()),
                                SizedBox(width: 320, child: buildChatSection()),
                              ],
                            ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget buildCanvasSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(5),
          height: 50,
          margin: EdgeInsets.only(left: 5, top: 5),
          decoration: BoxDecoration(
            color: Colors.orange[200],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.red,
                child: Text('1', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 8),
              Expanded(child: Text("Player is drawing")),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: textBlankWidget,
              ),
            ],
          ),
        ),

        SizedBox(height: 5),

        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),

        SizedBox(height: 5),

        Container(
          height: 50,
          margin: EdgeInsets.only(left: 5, bottom: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Toolbar(),
        ),
      ],
    );
  }

  Widget buildChatSection() {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Chat",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 10),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var msg = messages[index].values;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${msg.elementAt(0)} :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          msg.elementAt(1),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 10),

          TextField(
            controller: controller,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                Map map = {
                  'username': widget.data['nickname'],
                  'msg': value.trim(),
                  'word': dataOfRoom['word'],
                  'roomName': dataOfRoom['name'],
                };

                _socket.emit('msg', map);
                controller.clear();
              }
            },
            decoration: InputDecoration(
              hintText: "Type your guess...",
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
