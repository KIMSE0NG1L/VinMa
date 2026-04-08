import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    required this.isLoggedIn,
    required this.email,
    required this.onLogin,
    required this.onLogout,
    super.key,
  });

  final bool isLoggedIn;
  final String email;
  final ValueChanged<String> onLogin;
  final VoidCallback onLogout;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoggedIn) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        children: [
          Text(
            '마이 빈마',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '구매 내역, 판매 상품, 배송 상태를 이곳에서 확인할 수 있습니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ProfileActionTile(
            icon: Icons.receipt_long_outlined,
            title: '주문 내역',
            subtitle: '결제와 배송 기록 확인',
            onTap: () {},
          ),
          _ProfileActionTile(
            icon: Icons.storefront_outlined,
            title: '판매 관리',
            subtitle: '등록한 빈티지 아이템 관리',
            onTap: () {},
          ),
          _ProfileActionTile(
            icon: Icons.shield_outlined,
            title: '안전거래 센터',
            subtitle: '거래 보호와 신고 기준 확인',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('로그아웃'),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 96),
      children: [
        Icon(
          Icons.person_outline,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 18),
        Text(
          '빈마에 로그인',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          '가방, 판매자 프로필, 빈티지 거래 기록을 저장하세요.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: '이메일',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _submit, child: const Text('계속하기')),
      ],
    );
  }

  void _submit() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      return;
    }

    widget.onLogin(email);
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
