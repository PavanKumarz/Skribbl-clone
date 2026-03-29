import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:skribbl_clone/models/my_custom_painter.dart';
import 'package:skribbl_clone/models/touch_points.dart';
import 'package:skribbl_clone/screens/onboarding_page.dart';
import 'package:skribbl_clone/screens/waiting_room_page.dart';
import 'package:skribbl_clone/widgets/final_leaderboard.dart';
import 'package:skribbl_clone/widgets/paint_score_strip.dart';
import 'package:skribbl_clone/widgets/paint_word_display.dart';
import 'package:skribbl_clone/widgets/player_scoreboard_drawer.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

class DoodlePage extends StatefulWidget {
  final Map<String, String> data;

  final String screenFrom;

  const DoodlePage({super.key, required this.data, required this.screenFrom});

  @override
  State<DoodlePage> createState() => _DoodlePageState();
}

class _DoodlePageState extends State<DoodlePage> {
  static String get _serverUrl {
    const defined = String.fromEnvironment('SKRIBBLE_SERVER_URL');
    if (defined.isNotEmpty) {
      return defined;
    }
    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      final scheme = Uri.base.scheme == 'https' ? 'https' : 'http';
      return '$scheme://$host:3000';
    }
    return 'https://unconstrictive-lory-sprier.ngrok-free.dev';
  }

  late io.Socket _socket;

  Map<String, dynamic>? dataOfRoom;

  Size _canvasSize = Size.zero;

  final List<TouchPoints?> points = [];

  StrokeCap strokeType = StrokeCap.round;

  Color selectedColor = Colors.black;

  double opacity = 1;

  double strokeWidth = 2;

  final List<Widget> textBlankWidget = [];

  final ScrollController _scrollController = ScrollController();

  final TextEditingController controller = TextEditingController();

  final List<Map<String, dynamic>> messages = [];

  int guessedUserCtr = 0;

  int _start = 60;

  Timer? _timer;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, String>> scoreboard = [];

  bool isTextInputReadOnly = false;

  int maxPoints = 0;

  String winner = '';

  bool isShowFinalLeaderboard = false;

  static const List<Color> _paletteColors = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    connect();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer?.cancel();
    _timer = Timer.periodic(oneSec, (Timer time) {
      if (_start == 0) {
        final room = dataOfRoom;
        if (room != null) {
          _socket.emit('change-turn', room['name']);
        }
        setState(() {
          _timer?.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text('_', style: TextStyle(fontSize: 30)));
    }
  }

  void _updateScoreboard(List<dynamic> players) {
    scoreboard
      ..clear()
      ..addAll(
        players.map(
          (player) => {
            'username': player['nickname'].toString(),
            'points': player['points'].toString(),
          },
        ),
      );
  }

  void connect() {
    _socket = io.io(_serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.onConnect((_) {
      if (widget.screenFrom == 'createRoom') {
        _socket.emit('create-game', widget.data);
      } else {
        _socket.emit('join-game', widget.data);
      }

      _socket.on('updateRoom', (roomData) {
        final room = Map<String, dynamic>.from(roomData as Map);
        setState(() {
          dataOfRoom = room;
          renderTextBlank(room['word'].toString());

          if (room['isJoin'] != true) {
            startTimer();
          }
          _updateScoreboard(room['players'] as List<dynamic>);
        });
      });

      _socket.on(
        'notCorrectGame',
        (_) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => OnboardingPage()),
          (route) => false,
        ),
      );

      _socket.on('points', (point) {
        if (point['details'] != null) {
          final details = Map<String, dynamic>.from(point['details'] as Map);
          final double dx;
          final double dy;
          if (details.containsKey('xRatio') &&
              details.containsKey('yRatio') &&
              _canvasSize != Size.zero) {
            dx = (details['xRatio'] as num).toDouble() * _canvasSize.width;
            dy = (details['yRatio'] as num).toDouble() * _canvasSize.height;
          } else {
            dx = (details['dx'] as num).toDouble();
            dy = (details['dy'] as num).toDouble();
          }
          setState(() {
            points.add(
              TouchPoints(
                points: Offset(dx, dy),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withValues(alpha: opacity)
                  ..strokeWidth = strokeWidth,
              ),
            );
          });
        } else {
          setState(() {
            points.add(null);
          });
        }
      });

      _socket.on('msg', (msgData) {
        setState(() {
          messages.add(Map<String, dynamic>.from(msgData as Map));
          guessedUserCtr = msgData['guessedUserCtr'] as int;
        });

        final room = dataOfRoom;
        if (room != null && guessedUserCtr == (room['players'].length - 1)) {
          _socket.emit('change-turn', room['name']);
        }

        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 40,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      });

      _socket.on('change-turn', (data) {
        final oldWord = dataOfRoom?['word']?.toString() ?? '';
        showDialog(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 3), () {
              if (!mounted) return;
              final updatedRoom = Map<String, dynamic>.from(data as Map);
              setState(() {
                dataOfRoom = updatedRoom;
                renderTextBlank(updatedRoom['word'].toString());
                isTextInputReadOnly = false;
                guessedUserCtr = 0;
                _start = 60;
                points.clear();
              });
              Navigator.of(this.context).pop();
              _timer?.cancel();
              startTimer();
            });
            return AlertDialog(title: Center(child: Text('Word was $oldWord')));
          },
        );
      });

      _socket.on('updateScore', (roomData) {
        final room = Map<String, dynamic>.from(roomData as Map);
        setState(() {
          _updateScoreboard(room['players'] as List<dynamic>);
        });
      });

      _socket.on('show-leaderboard', (roomPlayers) {
        final players = List<dynamic>.from(roomPlayers as List<dynamic>);
        maxPoints = 0;
        winner = '';
        _updateScoreboard(players);
        for (final player in scoreboard) {
          final currentPoints = int.tryParse(player['points'] ?? '0') ?? 0;
          if (maxPoints < currentPoints) {
            winner = player['username'] ?? '';
            maxPoints = currentPoints;
          }
        }
        setState(() {
          _timer?.cancel();
          isShowFinalLeaderboard = true;
        });
      });

      _socket.on('color-change', (colorString) {
        final value = int.parse(colorString.toString(), radix: 16);
        setState(() {
          selectedColor = Color(value);
        });
      });

      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });

      _socket.on('clear-screen', (_) {
        setState(() {
          points.clear();
        });
      });

      _socket.on('closeInput', (_) {
        _socket.emit('updateScore', widget.data['name'] ?? '');
        setState(() {
          isTextInputReadOnly = true;
        });
      });

      _socket.on('user-disconnected', (data) {
        final room = Map<String, dynamic>.from(data as Map);
        setState(() {
          _updateScoreboard(room['players'] as List<dynamic>);
        });
      });
    });

    _socket.onConnectError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to connect to server at $_serverUrl')),
      );
    });

    _socket.onError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Socket error. Please try again.')),
      );
    });

    _socket.connect();
  }

  void _selectColor(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              final colorString = color.toString();
              final valueString = colorString.split('(0x')[1].split(')')[0];
              _socket.emit('color-change', {
                'color': valueString,
                'roomName': room['name'],
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _emitColorChange(Color color, String roomName) {
    final valueString = color.toARGB32().toRadixString(16).padLeft(8, '0');
    _socket.emit('color-change', {'color': valueString, 'roomName': roomName});
  }

  Widget _buildPaintingCanvas({
    required bool myTurn,
    required String roomName,
    required double width,
    required double height,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Container(
      width: isDesktop ? width - 320 : width - 24,
      height: isDesktop
          ? (height * 0.48).clamp(260.0, 520.0)
          : isTablet
          ? (height * 0.36).clamp(240.0, 420.0)
          : (height * 0.27).clamp(190.0, 320.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

          Map<String, dynamic> normalizedDetails(Offset localPosition) {
            final xRatio = _canvasSize.width == 0
                ? 0.0
                : (localPosition.dx / _canvasSize.width).clamp(0.0, 1.0);
            final yRatio = _canvasSize.height == 0
                ? 0.0
                : (localPosition.dy / _canvasSize.height).clamp(0.0, 1.0);
            return {
              'dx': localPosition.dx,
              'dy': localPosition.dy,
              'xRatio': xRatio,
              'yRatio': yRatio,
            };
          }

          return GestureDetector(
            onPanUpdate: myTurn
                ? (details) {
                    _socket.emit('paint', {
                      'details': normalizedDetails(details.localPosition),
                      'roomName': roomName,
                    });
                  }
                : null,
            onPanStart: myTurn
                ? (details) {
                    _socket.emit('paint', {
                      'details': normalizedDetails(details.localPosition),
                      'roomName': roomName,
                    });
                  }
                : null,
            onPanEnd: myTurn
                ? (_) {
                    _socket.emit('paint', {
                      'details': null,
                      'roomName': roomName,
                    });
                  }
                : null,
            child: SizedBox.expand(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: MyCustomPainter(pointsList: points),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolBar({required bool myTurn, required String roomName}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCDE8FF)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.color_lens, color: selectedColor),
            onPressed: myTurn ? () => _selectColor(dataOfRoom!) : null,
          ),
          Expanded(
            child: Slider(
              min: 1.0,
              max: 10,
              label: 'Stroke ${strokeWidth.toStringAsFixed(1)}',
              activeColor: selectedColor,
              value: strokeWidth,
              onChanged: myTurn
                  ? (value) {
                      _socket.emit('stroke-width', {
                        'value': value,
                        'roomName': roomName,
                      });
                    }
                  : null,
            ),
          ),
          Container(
            width: 34,
            alignment: Alignment.center,
            child: Text(
              strokeWidth.toStringAsFixed(0),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E2A4A),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.layers_clear, color: selectedColor),
            onPressed: myTurn
                ? () => _socket.emit('clean-screen', roomName)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPalette({required bool myTurn, required String roomName}) {
    if (!myTurn) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _paletteColors.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final color = _paletteColors[index];
            final selected = selectedColor.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: () => _emitColorChange(color, roomName),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: selected ? 34 : 28,
                height: selected ? 34 : 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: selected ? const Color(0xFF1E2A4A) : Colors.white,
                    width: selected ? 3 : 2,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessagesPanel() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EEFF).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE3D4FF)),
        ),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final username =
                msg['username']?.toString() ??
                msg.values.elementAt(0).toString();
            final body =
                msg['msg']?.toString() ?? msg.values.elementAt(1).toString();
            return ListTile(
              dense: true,
              title: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4A7BFF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    username,
                    style: const TextStyle(
                      color: Color(0xFF1E2A4A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF5C6785),
                    fontSize: 14,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuessInput({
    required bool myTurn,
    required bool isDesktop,
    required double width,
    required Map<String, dynamic> room,
  }) {
    if (myTurn) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        constraints: BoxConstraints(maxWidth: isDesktop ? width - 340 : width),
        child: TextField(
          readOnly: isTextInputReadOnly,
          controller: controller,
          onSubmitted: (value) {
            if (value.trim().isEmpty) return;
            _socket.emit('msg', {
              'username': widget.data['nickname'],
              'msg': value.trim(),
              'word': room['word'],
              'roomName': widget.data['name'],
              'guessedUserCtr': guessedUserCtr,
              'totalTime': 60,
              'timeTaken': 60 - _start,
            });
            controller.clear();
          },
          autocorrect: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFFFF1DE),
            hintText: 'Your Guess',
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socket.dispose();
    _timer?.cancel();
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final room = dataOfRoom;
    final isDesktop = width >= 1100;
    final isTablet = width >= 760;
    final isPhone = width < 600;
    final timeProgress = (_start / 60).clamp(0.0, 1.0);

    if (room == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLobby = room['isJoin'] == true;
    final myTurn = room['turn']?['nickname'] == widget.data['nickname'];
    final roomName = room['name'].toString();
    final wordText = room['word'].toString();

    final rankedScoreboard = [...scoreboard]
      ..sort(
        (a, b) => (int.tryParse(b['points'] ?? '0') ?? 0).compareTo(
          int.tryParse(a['points'] ?? '0') ?? 0,
        ),
      );
    final currentNickname = widget.data['nickname'] ?? '';

    return Scaffold(
      key: scaffoldKey,
      drawer: isDesktop ? null : PlayerScore(scoreboard),
      backgroundColor: const Color(0xFFF4F7FF),
      body: isLobby
          ? WaitingRoomPage(
              lobbyName: room['name'],
              noOfPlayers: room['players'].length,
              occupancy: room['occupancy'],
              players: room['players'],
            )
          : isShowFinalLeaderboard
          ? FinalLeaderboard(scoreboard, winner)
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE8F0FF),
                        Color(0xFFFFF1E8),
                        Color(0xFFE7FFF5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(right: isDesktop ? 296 : 0),
                    child: Column(
                      children: [
                        SizedBox(height: isPhone ? 14 : 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3DD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFFD58B),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: isPhone ? 14 : 18,
                                  backgroundColor: const Color(0xFFE8EEFF),
                                  child: Text(
                                    '${_start.clamp(0, 60)}',
                                    style: TextStyle(
                                      fontSize: isPhone ? 11 : 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E2A4A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    myTurn
                                        ? 'Your turn to draw'
                                        : '${room['turn']['nickname']} is drawing',
                                    style: TextStyle(
                                      fontSize: isPhone ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E2A4A),
                                    ),
                                  ),
                                ),
                                if (!isPhone)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFD8FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      roomName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E2A4A),
                                      ),
                                    ),
                                  ),
                                if (!isDesktop) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () =>
                                        scaffoldKey.currentState?.openDrawer(),
                                    icon: const Icon(Icons.leaderboard),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: timeProgress,
                              backgroundColor: const Color(0xFFD9E3FF),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _start > 15
                                    ? const Color(0xFF4A7BFF)
                                    : const Color(0xFFFF6B6B),
                              ),
                            ),
                          ),
                        ),
                        if (isPhone)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFD8FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  roomName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E2A4A),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (!isDesktop)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: PaintScoreStrip(
                              rankedScoreboard: rankedScoreboard,
                              currentNickname: currentNickname,
                            ),
                          ),
                        const SizedBox(height: 12),
                        _buildPaintingCanvas(
                          myTurn: myTurn,
                          roomName: roomName,
                          width: width,
                          height: height,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                        ),
                        _buildToolBar(myTurn: myTurn, roomName: roomName),
                        _buildPalette(myTurn: myTurn, roomName: roomName),
                        const SizedBox(height: 8),
                        PaintWordDisplay(
                          myTurn: myTurn,
                          wordText: wordText,
                          blanksCount: textBlankWidget.length,
                        ),
                        const SizedBox(height: 4),
                        _buildMessagesPanel(),
                        SizedBox(height: !myTurn ? 70 : 16),
                      ],
                    ),
                  ),
                ),
                if (isDesktop)
                  Positioned(
                    right: 12,
                    top: 18,
                    bottom: 18,
                    child: SizedBox(
                      width: 280,
                      child: PaintScorePanel(
                        rankedScoreboard: rankedScoreboard,
                        currentNickname: currentNickname,
                      ),
                    ),
                  ),
                _buildGuessInput(
                  myTurn: myTurn,
                  isDesktop: isDesktop,
                  width: width,
                  room: room,
                ),
              ],
            ),
    );
  }
}
