import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:uuid/uuid.dart';
import 'package:uni_links/uni_links.dart';

class ChopChopPage extends StatefulWidget {
  const ChopChopPage({super.key});

  @override
  State<ChopChopPage> createState() => _ChopChopPageState();
}

class _ChopChopPageState extends State<ChopChopPage> {
  final TextEditingController goalController = TextEditingController();
  List<String> tones = [];
  String? selectedTone;
  bool isLoadingTones = true;
  String chopchopMessage = "Discipline is choosing between what you want now and what you want most.";
  int selectedYear = DateTime.now().year;
  int? selectedMonth; // 1-12
  int? selectedDay;
  String? selectedDateText;

  DateTime? selectedDate;
  String? userId;

  @override
  void initState() {
    super.initState();
    _initUserId();
    _fetchToneOptions();
    _handleDeepLinks();
  }

  void _handleDeepLinks() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleUri(initialUri);
      }

      uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleUri(uri);
        }
      });
    } catch (e) {
      print('❌ Failed to handle deep link: $e');
    }
  }

  void _handleUri(Uri uri) async {
    print('🔗 Received URI: $uri');
    if (uri.scheme == 'chopchopai' && uri.host == 'refresh') {
      if (userId == null) return;
      final message = await _fetchTodayMotivation();
      await _updateWidgetText(message);
      setState(() {
        chopchopMessage = message;
      });
      print('✅ Widget refreshed from deep link');
    }
  }

  Future<void> _initUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString("user_id");

    if (existing != null) {
      setState(() => userId = existing);
    } else {
      final newId = const Uuid().v4();
      await prefs.setString("user_id", newId);
      setState(() => userId = newId);
    }
  }

  Future<void> _fetchToneOptions() async {
    final res = await http.get(Uri.parse("https://chopchoppython.onrender.com/tones")); // Replace with your actual URL
    if (res.statusCode == 200) {
      final List<dynamic> result = jsonDecode(res.body)['tones'];
      setState(() {
        tones = result.map((e) => e.toString()).toList();
        selectedTone = tones.first;
        isLoadingTones = false;
      });
    } else {
      // fallback in case of error
      setState(() {
        tones = ["TED talker"];
        selectedTone = tones.first;
        isLoadingTones = false;
      });
    }
  }

  void _showToneSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C1A4C), // dark purple
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: tones.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10),
          itemBuilder: (context, index) {
            final tone = tones[index];
            return ListTile(
              title: Text(
                tone,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              trailing: selectedTone == tone
                  ? const Icon(Icons.check_circle, color: Colors.white70)
                  : null,
              onTap: () {
                setState(() {
                  selectedTone = tone;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8A4FFF), Color(0xFFFF8F71)], // Purple to coral gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "ChopChopAI",
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                chopchopMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Your Goal",
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: goalController,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                color: Colors.white
                ),
              maxLines: 3, // Allow multiple lines of text
              textInputAction: TextInputAction.newline, // Enable newline on enter
              keyboardType: TextInputType.multiline, // Use multiline keyboard
              decoration: InputDecoration(
                hintText: "E.g. Build a startup",
                hintStyle: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  color: Colors.white70
                  ),
                filled: true,
                fillColor: Colors.white24, // Lighter background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // Remove border
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Tone of motivator",
              style: TextStyle(
                // fontFamily: 'SF Pro Display',
                color: Colors.white70, 
                fontSize: 14
              ),
            ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showToneSelector(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedTone ?? "Select a tone",
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              "Deadline",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showCustomDeadlinePickerModal,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white24, // Lighter background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent), // Remove border
                ),
                child: Text(
                  selectedDateText ?? "Tap to pick year / month / date",
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                      fontSize: 16,
                    ),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (goalController.text.isEmpty || userId == null) return;

                  final goalData = {
                    "goal": goalController.text,
                    "deadline": selectedDate?.toIso8601String() ?? "",
                    "tone": selectedTone,
                    "user_id": userId
                  };

                  final url = Uri.parse("https://chopchoppython.onrender.com/goal"); // Replace with your backend URL

                  final res = await http.post(url,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode(goalData));

                  if (res.statusCode == 200) {
                    final message = await _fetchTodayMotivation();
                    await _updateWidgetText(message);
                    setState(() {
                      chopchopMessage = message;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🎉 Goal saved and widget refreshed")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("❌ Failed to save goal")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAA4FD0), // Purple button
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // More rounded
                  ),
                ),
                child: const Text("Set goal", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDeadlinePickerModal() {
    final currentYear = DateTime.now().year;
    final years = List.generate(11, (index) => currentYear + index);
    final months = [null, ...List.generate(12, (index) => index + 1)];
    final days = [null, ...List.generate(31, (index) => index + 1)];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8A4FFF), Color(0xFFFF8F71)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Pick Deadline",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // const SizedBox(height: 5),
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                          initialItem: 0,
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() => selectedYear = years[index]);
                        },
                        children: years
                            .map((y) => Center(
                              child: Text(
                                y.toString(),
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  color: Colors.white,
                                ),
                              ),
                            ))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() => selectedMonth = months[index]);
                        },
                        children: months
                            .map((m) => Center(
                              child: Text(
                                m == null ? "None" : DateFormat.MMMM().format(DateTime(0, m)),
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  color: Colors.white,
                                ),
                              ),
                            ))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() => selectedDay = days[index]);
                        },
                        children: days
                            .map((d) => Center(
                              child: Text(
                                d == null ? "None" : d.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  color: Colors.white,
                                ),
                              ),
                            ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (selectedMonth == null && selectedDay != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("⚠️ Select month before picking a date")),
                    );
                    return;
                  }

                  DateTime now = DateTime.now();
                  DateTime? temp;

                  if (selectedMonth == null && selectedDay == null) {
                    // Year only
                    temp = DateTime(selectedYear);
                    if (temp.year < now.year) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("❌ Can't set a past year")),
                      );
                      return;
                    }
                    setState(() => selectedDate = null); // We'll store separately
                    setState(() => selectedDateText = selectedYear.toString());
                  } else if (selectedMonth != null && selectedDay == null) {
                    temp = DateTime(selectedYear, selectedMonth!);
                    if (temp.isBefore(now)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("❌ Can't set a past month")),
                      );
                      return;
                    }
                    setState(() => selectedDate = null);
                    setState(() => selectedDateText =
                        "${DateFormat.yMMM().format(temp!)}"); // e.g. Apr 2025
                  } else if (selectedMonth != null && selectedDay != null) {
                    try {
                      temp = DateTime(selectedYear, selectedMonth!, selectedDay!);
                      if (temp.isBefore(now)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("❌ Can't set a past date")),
                        );
                        return;
                      }
                      setState(() {
                        selectedDate = temp;
                        selectedDateText = DateFormat.yMMMMd().format(temp!);
                      });
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("❌ Invalid date")),
                      );
                      return;
                    }
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF8A4FFF),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text("Done", style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        );
      },
    );
  }

  Future<String> _fetchTodayMotivation() async {
    final uri = Uri.parse("https://chopchoppython.onrender.com/motivation/today?user_id=$userId");
    final res = await http.get(uri);
    final json = jsonDecode(res.body);
    return json["message"] ?? "Keep pushing!";
  }

  Future<void> _updateWidgetText(String text) async {
    final widgetData = {
      "text": text,
      "goal": goalController.text
    };
    
    final widgetJson = jsonEncode(widgetData);
    await WidgetKit.setItem("widgetData", widgetJson, "group.com.parth.flutterWidgetTest");
    WidgetKit.reloadAllTimelines();
  }
}
