import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/api/client.dart';
import 'package:mobile/widgets/user_menu_button.dart'; // Your user menu widget

import '../widgets/create_request_modal.dart';

class PersistentSearchPage extends StatefulWidget {
  const PersistentSearchPage({super.key});

  @override
  _PersistentSearchPageState createState() => _PersistentSearchPageState();
}

class Request {
  final int id;
  final String content;
  final String user;
  final int budget;
  final String currency;
  final String? location;
  final int? radius;
  final String createdAt;

  Request({
    required this.id,
    required this.content,
    required this.user,
    required this.budget,
    required this.currency,
    required this.location,
    required this.radius,
    required this.createdAt,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    try {
      return Request(
        id: json['id'],
        content: json['content'],
        user: json['user']['username'],
        budget: json['budget'],
        currency: json['currency'],
        location: json['location']?.toString() ?? 'N/A',
        radius: json['radius'] ?? 0,
        createdAt: json['createdAt'],
      );
    } catch (e) {
      throw Exception('Failed to parse request data');
    }
  }
}

class _PersistentSearchPageState extends State<PersistentSearchPage> {
  final TextEditingController _controller = TextEditingController();
  String query = '';
  Future<List<Request>>? futureItems;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    futureItems = fetchItems(query);
  }

  Future<List<Request>> fetchItems(String query) async {
    try {
      final dio = useApi();
      final response = await dio.get(
        '/request',
        queryParameters: query.isNotEmpty ? {'content': query} : null,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      if (response.statusCode == 200) {
        if (response.data is List) {
          List<dynamic> data = response.data;
          return data
              .map((item) => Request.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch items');
      }
    } on DioException {
      throw Exception('Network error. Please check your connection.');
    }
    // final dio = useApi();
    // final response = await dio.get(
    //   '/request',
    //   queryParameters: {'content': query},
    // );
    //
    // if (response.statusCode == 200) {
    //   List<dynamic> data = response.data;
    //   return data.map((item) => Request.fromJson(item)).toList();
    // } else {
    //   throw Exception('Failed to fetch items');
    // }
  }

  void _search(String input) {
    setState(() {
      query = input;
      futureItems = fetchItems(query);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // You can add navigation or page switching logic here
    });
  }

  String _formatCurrency(int budget, String currency) {
    try {
      final format = NumberFormat.simpleCurrency(
        locale: 'en_US',
        name: currency,
      );
      return '${format.currencySymbol}$budget';
    } catch (e) {
      return '$currency $budget';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WantIt'),
        actions: const [UserMenuButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Request>>(
              future: futureItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No results found.'));
                }

                final items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.content,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(item.budget, item.currency),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  item.user,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            isScrollControlled: true,
            builder: (context) => const CreateRequestModal(),
          );
        },
        tooltip: 'Create Request',
        child: const Icon(Icons.add),
      ),
    );
  }
}
