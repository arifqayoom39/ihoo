import 'package:ihoo/controllers/auth_service.dart';
import 'package:ihoo/providers/cart_provider.dart';
import 'package:ihoo/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:ihoo/views/privacy_policy.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color flipkartBlue = const Color(0xFF2874F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: flipkartBlue,
        elevation: 0,
        title: const Text(
          "My Account",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 8),
            _buildOrdersSection(),
            const SizedBox(height: 8),
            _buildAccountSettings(),
            const SizedBox(height: 8),
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<UserProvider>(
      builder: (context, value, child) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  // ignore: deprecated_member_use
                  backgroundColor: flipkartBlue.withOpacity(0.2),
                  child: Text(
                    value.name.isNotEmpty ? value.name[0].toUpperCase() : '',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: flipkartBlue),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value.email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: flipkartBlue),
                  onPressed: () => Navigator.pushNamed(context, "/update_profile"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildSectionHeader("My Orders"),
          InkWell(
            onTap: () => Navigator.pushNamed(context, "/orders"),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: flipkartBlue, size: 28),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Orders & Returns",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildSectionHeader("Account Settings"),
          _buildMenuItem(
            "Discount & Offers",
            Icons.local_offer_outlined,
            () => Navigator.pushNamed(context, "/discount"),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            "Logout",
            Icons.power_settings_new,
            () async {
              Provider.of<UserProvider>(context, listen: false).cancelProvider();
              Provider.of<CartProvider>(context, listen: false).cancelProvider();
              await AuthService().logout();
              Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildSectionHeader("Help & Support"),
          _buildMenuItem(
            "24x7 Customer Care",
            Icons.support_agent,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Mail us at arifqayoom39@flash.co"))
              );
            },
          ),
          const Divider(height: 1),
_buildMenuItem(
  "Privacy Policy",
  Icons.privacy_tip_outlined,
  () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
  ),
),

        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: flipkartBlue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
