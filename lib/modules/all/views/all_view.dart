import 'package:flutter/material.dart';

class AllView extends StatelessWidget {
  const AllView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black),
          onPressed: () {},
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            const Text(
              'Hemmesi',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: const [
              JobCard(
                date: '27 awgust 2023, 16:31',
                title: 'Aşhanadaky smesitel we turba akýar',
                isNew: false,
              ),
              SizedBox(height: 16),
              JobCard(
                date: '27 awgust 2023, 16:31',
                title: 'Aşhanadaky smesitel we turba akýar',
                isNew: true,
              ),
              // Add more JobCard widgets as needed
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.account_balance_wallet,
                              color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Hasabym: 375 TMT',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.login, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Giriňişleýin',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String date;
  final String title;
  final bool isNew;

  const JobCard({
    super.key,
    required this.date,
    required this.title,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.access_time, color: Colors.blue, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Täze',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              '24.05.2023 - 28.05.2023',
              'işiň senesi',
            ),
            _buildInfoRow(
              Icons.business,
              'Gurluşyk we abatlaýyş',
              null,
            ),
            _buildInfoRow(
              Icons.location_on,
              'Aşgabat, Mir 7/2, Jaý 9, Otag 32',
              null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSmallInfo(Icons.money, '750 TMT - 8000 TMT'),
                const SizedBox(width: 16),
                _buildSmallInfo(Icons.person, '10'),
                const SizedBox(width: 16),
                _buildSmallInfo(Icons.remove_red_eye, '48'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, String? suffix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
          if (suffix != null)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                suffix,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
