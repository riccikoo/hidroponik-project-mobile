import 'package:flutter/material.dart';
import '../services/shared_service.dart';
import '../services/api_service.dart';
import '../models/message_model.dart';

class ClientMessagePage extends StatefulWidget {
  const ClientMessagePage({super.key});

  @override
  State<ClientMessagePage> createState() => _ClientMessagePageState();
}

class _ClientMessagePageState extends State<ClientMessagePage> {
  // Color theme
  final Color darkGreen = const Color(0xFF456028);
  final Color mediumGreen = const Color(0xFF94A65E);
  final Color accentBlue = const Color(0xFF5A86AD);
  final Color userMessageBg = const Color(0xFFE3F2FD);
  final Color adminMessageBg = const Color(0xFFF5F5F5);
  final Color cardSurface = const Color(0xFFFFFFFF);

  // State
  List<UserMessage> _messages = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _token;

  // Chat input
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // User info
  int? _currentUserId;
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMessages();

    // Auto scroll ke bottom setelah build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userMap = await SharedService.getUserAsMap();

      if (userMap != null) {
        print('📋 User Map from SharedPrefs: $userMap');
        print('📋 User ID type: ${userMap['id']?.runtimeType}');
        print('📋 User ID value: ${userMap['id']}');

        setState(() {
          // Handle berbagai kemungkinan tipe data ID
          final dynamic idValue = userMap['id'];

          if (idValue is int) {
            _currentUserId = idValue;
          } else if (idValue is String) {
            _currentUserId = int.tryParse(idValue) ?? 0;
          } else if (idValue is double) {
            _currentUserId = idValue.toInt();
          } else {
            _currentUserId = 0;
          }

          _currentUserName = (userMap['name'] as String?) ?? 'You';
        });

        print('✅ Parsed User ID: $_currentUserId');
        print('✅ Parsed User Name: $_currentUserName');
      } else {
        print('⚠️ User map is null');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      _token = await SharedService.getToken();
      if (_token == null || _token!.isEmpty) {
        throw Exception('No authentication token found. Please login again.');
      }

      final messages = await ApiService.getUserMessages(_token!);

      // Sort messages by timestamp ascending untuk chat timeline
      messages.sort(
        (a, b) => (a.timestamp ?? DateTime.now()).compareTo(
          b.timestamp ?? DateTime.now(),
        ),
      );

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      // Scroll ke bottom setelah loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint('Error loading messages: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load messages: ${e.toString()}';
        _messages = [];
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      _showSnackBar('Please enter a message', Colors.orange);
      return;
    }

    try {
      setState(() => _isSending = true);

      if (_token != null) {
        final success = await ApiService.sendMessageToAdmin(_token!, message);

        if (success) {
          // Add optimistic update
          final newMessage = UserMessage(
            id: DateTime.now().millisecondsSinceEpoch,
            senderId: _currentUserId ?? 0,
            receiverId: 1, // Admin ID
            message: message,
            isRead: false,
            timestamp: DateTime.now(),
            sender: Sender(
              id: _currentUserId ?? 0,
              name: _currentUserName ?? 'You',
              email: '',
            ),
          );

          setState(() {
            _messages.add(newMessage);
          });

          // Clear input
          _messageController.clear();

          // Scroll to bottom
          _scrollToBottom();

          // Refresh from server after delay
          Future.delayed(const Duration(seconds: 1), () {
            _loadMessages();
          });

          _showSnackBar('Message sent successfully!', Colors.green);
        } else {
          throw Exception('Failed to send message');
        }
      }
    } catch (e) {
      debugPrint('Send message error: $e');
      _showSnackBar('Failed to send message', Colors.red);
    } finally {
      setState(() => _isSending = false);
      _focusNode.requestFocus();
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool _isCurrentUser(UserMessage message) {
    return message.senderId == _currentUserId;
  }

  bool _isAdmin(UserMessage message) {
    return message.senderId == 1 || !_isCurrentUser(message);
  }

  String _getSenderName(UserMessage message) {
    if (_isCurrentUser(message)) {
      return 'You';
    } else if (_isAdmin(message)) {
      return 'Admin';
    } else {
      return message.sender?.name ?? 'Unknown';
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkGreen,
        elevation: 2,
        shadowColor: darkGreen.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Color(0xFF456028),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Support',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Always available',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFF8F9FA),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chat with system administrator for assistance',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),

          // Messages area
          Expanded(child: _buildMessagesList()),

          // Message input area
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(darkGreen),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading conversation...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load messages',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Please try again',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadMessages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.message_rounded, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start a conversation with admin',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _focusNode.requestFocus();
                },
                icon: const Icon(Icons.message_rounded),
                label: const Text('Say Hello'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF8F9FA),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isCurrentUser = _isCurrentUser(message);
          final senderName = _getSenderName(message);

          // Check if we should show time separator
          bool showTimeSeparator =
              index == 0 ||
              _isDifferentDay(
                _messages[index - 1].timestamp,
                message.timestamp,
              );

          return Column(
            children: [
              // Time separator
              if (showTimeSeparator) _buildTimeSeparator(message.timestamp),

              // Message bubble
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: isCurrentUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar for admin (left side)
                    if (!isCurrentUser)
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF456028),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),

                    // Message content
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // Sender name (only for admin messages)
                            if (!isCurrentUser)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 4,
                                  left: 12,
                                ),
                                child: Text(
                                  senderName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                            // Message bubble
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? accentBlue
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                                border: !isCurrentUser
                                    ? Border.all(color: Colors.grey.shade200)
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.message ?? '',
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(message.timestamp),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isCurrentUser
                                              ? Colors.white.withOpacity(0.8)
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isCurrentUser)
                                        Icon(
                                          message.isRead
                                              ? Icons.done_all_rounded
                                              : Icons.done_rounded,
                                          size: 12,
                                          color: isCurrentUser
                                              ? Colors.white.withOpacity(0.8)
                                              : Colors.grey.shade500,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Avatar for user (right side)
                    if (isCurrentUser)
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5A86AD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeSeparator(DateTime? date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatDateForSeparator(date),
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Message input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Type your message here...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Emoji picker
                      },
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey,
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: darkGreen,
                boxShadow: [
                  BoxShadow(
                    color: darkGreen.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isDifferentDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year != date2.year ||
        date1.month != date2.month ||
        date1.day != date2.day;
  }

  String _formatDateForSeparator(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(date.year, date.month, date.day);

    if (messageDay.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (messageDay.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      final dayName = days[date.weekday % 7];
      final monthName = months[date.month - 1];

      return '$dayName, $monthName ${date.day}';
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';

    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12
        ? hour - 12
        : hour == 0
        ? 12
        : hour;

    return '$displayHour:$minute $period';
  }
}
