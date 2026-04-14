import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialChatScreen extends StatefulWidget {
  const SocialChatScreen({Key? key}) : super(key: key);

  @override
  State<SocialChatScreen> createState() => _SocialChatScreenState();
}

class _SocialChatScreenState extends State<SocialChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedTab = 'friends'; // friends, experts, group

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect & Share'),
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddChatDialog(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Tab Bar
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabButton('👥 Friends', 'friends'),
                    const SizedBox(width: 8),
                    _buildTabButton('🏥 Experts', 'experts'),
                    const SizedBox(width: 8),
                    _buildTabButton('👨‍👩‍👧‍👦 Groups', 'group'),
                  ],
                ),
              ),
            ),
          ),

          // Chat List
          if (_selectedTab == 'friends')
            _buildChatList('friends'),
          if (_selectedTab == 'experts')
            _buildExpertList(),
          if (_selectedTab == 'group')
            _buildGroupChatList(),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5CF6)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(String type) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final chats = [
            {
              'name': 'Sarah Johnson',
              'avatar': '👩‍🦰',
              'lastMessage': 'That recipe looks great! I\'ll try it tomorrow',
              'timestamp': '2 mins ago',
              'unread': 2,
              'status': 'online',
            },
            {
              'name': 'Alex Kumar',
              'avatar': '👨‍💼',
              'lastMessage': 'How was your workout today?',
              'timestamp': '1 hour ago',
              'unread': 0,
              'status': 'offline',
            },
            {
              'name': 'Emma Wilson',
              'avatar': '👩‍🎓',
              'lastMessage': 'Let\'s plan next week\'s meal prep!',
              'timestamp': '3 hours ago',
              'unread': 0,
              'status': 'online',
            },
            {
              'name': 'Raj Patel',
              'avatar': '👨‍🏭',
              'lastMessage': 'Thanks for the fitness tips!',
              'timestamp': '1 day ago',
              'unread': 0,
              'status': 'offline',
            },
          ];

          if (index >= chats.length) {
            return const SizedBox.shrink();
          }

          final chat = chats[index];

          return _buildChatTile(chat);
        },
        childCount: 4,
      ),
    );
  }

  Widget _buildExpertList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final experts = [
            {
              'name': 'Dr. Priya Sharma',
              'title': 'Nutritionist',
              'specialty': 'Diabetes Management',
              'avatar': '👩‍⚕️',
              'rating': 4.9,
              'price': '₹500/consultation',
              'available': true,
            },
            {
              'name': 'Arun Fitness',
              'title': 'Fitness Trainer',
              'specialty': 'Weight Loss Programs',
              'avatar': '💪',
              'rating': 4.7,
              'price': '₹400/session',
              'available': true,
            },
            {
              'name': 'Dr. Anjali Verma',
              'title': 'General Practitioner',
              'specialty': 'Health Consultation',
              'avatar': '👨‍⚕️',
              'rating': 4.8,
              'price': '₹600/consultation',
              'available': false,
            },
          ];

          if (index >= experts.length) {
            return const SizedBox.shrink();
          }

          final expert = experts[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildExpertCard(expert),
          );
        },
        childCount: 3,
      ),
    );
  }

  Widget _buildGroupChatList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final groups = [
            {
              'name': 'Fitness Squad 2026',
              'avatar': '💪',
              'members': 24,
              'lastMessage': 'Great workout session today!',
              'timestamp': '10 mins ago',
            },
            {
              'name': 'Healthy Recipes',
              'avatar': '🍳',
              'members': 156,
              'lastMessage': 'Check out this quinoa salad recipe!',
              'timestamp': '30 mins ago',
            },
            {
              'name': 'Medicine Reminder Buddies',
              'avatar': '💊',
              'members': 42,
              'lastMessage': 'Don\'t forget your evening meds!',
              'timestamp': '1 hour ago',
            },
          ];

          if (index >= groups.length) {
            return const SizedBox.shrink();
          }

          final group = groups[index];

          return _buildGroupChatTile(group);
        },
        childCount: 3,
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
              child: Text(chat['avatar'].toString(), style: const TextStyle(fontSize: 32)),
            ),
            if (chat['status'] == 'online')
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chat['name'].toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          chat['lastMessage'].toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chat['timestamp'].toString(),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            if ((chat['unread'] as int) > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Text(
                  chat['unread'].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _openChat(chat['name'].toString()),
      ),
    );
  }

  Widget _buildExpertCard(Map<String, dynamic> expert) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                child: Text(expert['avatar'].toString(), style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert['name'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      expert['title'].toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      expert['specialty'].toString(),
                      style: TextStyle(
                        color: const Color(0xFF8B5CF6),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        expert['rating'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expert['price'].toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (expert['available'] as bool)
                  ? () => _startExpertConsult(expert['name'].toString())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: expert['available'] as bool
                    ? const Color(0xFF8B5CF6)
                    : Colors.grey.withOpacity(0.3),
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
              ),
              child: Text(
                expert['available'] as bool ? 'Start Consultation' : 'Currently Unavailable',
                style: TextStyle(
                  color: expert['available'] as bool ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChatTile(Map<String, dynamic> group) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
          child: Text(group['avatar'].toString(), style: const TextStyle(fontSize: 32)),
        ),
        title: Text(
          group['name'].toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group['lastMessage'].toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              '${group['members']} members',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: Text(
          group['timestamp'].toString(),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
        onTap: () => _openGroupChat(group['name'].toString()),
      ),
    );
  }

  void _openChat(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening chat with $name')),
    );
  }

  void _openGroupChat(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joining $name group')),
    );
  }

  void _startExpertConsult(String expert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting consultation with $expert')),
    );
  }

  void _showAddChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Chat with Friend'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Consult an Expert'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Join a Group'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
