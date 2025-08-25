import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../core/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _topUpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      _nameController.text = appState.userName;
      _emailController.text = appState.userEmail;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _topUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👤 Profile SalGet"),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryGreen, width: 3),
                      ),
                      child: const CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
                      ),
                    ),
                    Positioned(
                      child: InkWell(
                        onTap: () {
                          _showChangePhotoDialog(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appState.userName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                appState.userEmail,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Center(
                            child: ElevatedButton.icon(
              onPressed: () {
                _showEditProfileDialog(context, appState);
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
              ),
              const SizedBox(height: 24),

              // Notifications Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "🔔 Notifikasi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (appState.unreadNotificationCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${appState.unreadNotificationCount} baru",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (appState.notifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "Belum ada notifikasi",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...appState.notifications.take(3).map(
                  (notification) => _buildNotificationCard(context, notification, appState),
                ),
              if (appState.notifications.length > 3)
                Center(
                  child: TextButton(
                    onPressed: () => _showAllNotifications(context, appState),
                    child: const Text("Lihat Semua Notifikasi"),
                  ),
                ),
              const SizedBox(height: 24),

              // Gopay Balance with modern design
              Container(
                padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                child: Row(
                  children: [
                                         Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: Colors.white.withValues(alpha: 0.2),
                         borderRadius: BorderRadius.circular(16),
                       ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Saldo Gopay",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Rp ${appState.gopayBalance.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showTopUpDialog(context, appState);
                      },
                                              style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      child: const Text(
                        "Top Up",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Order History
              const Text(
                "Riwayat Pesanan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              if (appState.orderHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Belum ada pesanan.",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...appState.orderHistory.map(
                  (order) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.receipt, color: Colors.orange),
                      title: Text("Pesanan #${order["id"].substring(0, 8)}"),
                      subtitle: Text("${order["date"].substring(0, 10)} • ${order["items"].length} item"),
                      trailing: Text(
                        "Rp ${order["total"].toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      onTap: () {
                        _showOrderDetailDialog(context, order);
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              const Text(
                "Pengaturan Akun",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.blue),
                title: const Text("Ganti Password"),
                onTap: () {
                  _showChangePasswordDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.deepPurple),
                title: const Text("Bantuan & Support"),
                onTap: () {
                  _showHelpDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.grey),
                title: const Text("Tentang Aplikasi"),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Gojek Clone",
                    applicationVersion: "1.0.0",
                    applicationLegalese: "© 2025 Gojek Clone\nAplikasi demo untuk pembelajaran",
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                label: const Text("Logout"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              appState.updateProfile(_nameController.text, _emailController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile berhasil diupdate! ✅")),
              );
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, AppState appState) {
    _topUpController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Top Up Gopay"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _topUpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah Top Up",
                prefixText: "Rp ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Pilih nominal cepat:",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [50000, 100000, 200000, 500000].map((amount) {
                return ActionChip(
                  label: Text("Rp ${amount.toStringAsFixed(0)}"),
                  onPressed: () {
                    _topUpController.text = amount.toString();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_topUpController.text);
              if (amount != null && amount > 0) {
                appState.topUpGopay(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Top up berhasil! Saldo: Rp ${appState.gopayBalance.toStringAsFixed(0)} ✅"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Top Up"),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailDialog(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detail Pesanan #${order["id"].substring(0, 8)}"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tanggal: ${order["date"].substring(0, 19).replaceAll('T', ' ')}"),
              Text("Status: ${order["status"]}"),
              const Divider(),
              const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order["items"].map<Widget>((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text("• ${item["name"]} (${item["size"]}, ${item["flavor"]}) x${item["quantity"]} - Rp ${item["price"].toStringAsFixed(0)}"),
              )).toList(),
              const Divider(),
              Text(
                "Total: Rp ${order["total"].toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showChangePhotoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ganti Foto Profil"),
        content: const Text("Fitur ini akan tersedia di versi selanjutnya!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ganti Password"),
        content: const Text("Fitur ini akan tersedia di versi selanjutnya!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bantuan & Support"),
        content: const Text("Hubungi kami di:\nEmail: support@gojekclone.com\nWhatsApp: +62 812-3456-7890"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pengaturan"),
        content: const Text("Fitur pengaturan akan tersedia di versi selanjutnya!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logout berhasil! 👋"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem notification, AppState appState) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.notifications, color: Colors.blue),
        title: Text(notification.title),
        subtitle: Text(notification.message),
        trailing: Text(
          notification.timestamp.toString().substring(0, 10),
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () {
          // Mark as read
          appState.markNotificationAsRead(notification.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Notifikasi terbuka!")),
          );
        },
      ),
    );
  }

  void _showAllNotifications(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Semua Notifikasi"),
        content: SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: appState.notifications.length,
            itemBuilder: (context, index) {
              final notification = appState.notifications[index];
              return ListTile(
                leading: const Icon(Icons.notifications, color: Colors.blue),
                title: Text(notification.title),
                subtitle: Text(notification.message),
                trailing: Text(
                  notification.timestamp.toString().substring(0, 10),
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  // Mark as read
                  appState.markNotificationAsRead(notification.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Notifikasi terbuka!")),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
