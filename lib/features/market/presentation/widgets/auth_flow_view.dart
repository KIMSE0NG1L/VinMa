import 'package:flutter/material.dart';

import '../../domain/user_profile.dart';

class AuthFlowView extends StatelessWidget {
  const AuthFlowView({
    required this.onKakaoLogin,
    super.key,
  });

  final Future<void> Function() onKakaoLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          children: [
            Text(
              '빈마온',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '좋은 빈티지를 발견하고, 사고, 다시 팔 수 있는 마켓',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6F665E),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&w=1200&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '내 옷장과 주문 내역을 한 곳에서 관리하세요',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '구매한 상품은 내 옷장에 쌓이고, 마음이 바뀌면 다시 판매로 이어집니다.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onKakaoLogin,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('카카오로 시작하기'),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F4F1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE7E1DA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _InfoRow(
                    icon: Icons.search_outlined,
                    title: '좋은 빈티지 상품 탐색',
                    description: '브랜드, 상태, 가격 흐름을 보고 원하는 상품을 찾습니다.',
                  ),
                  SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    title: '구매 후 내 옷장으로 정리',
                    description: '구매한 상품을 보관하고, 다시 판매할 준비를 할 수 있어요.',
                  ),
                  SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.local_shipping_outlined,
                    title: '주문과 배송 흐름 확인',
                    description: '주문 내역, 배송 상태, 재판매 흐름을 한곳에서 봅니다.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6F665E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingProfileFlow extends StatefulWidget {
  const OnboardingProfileFlow({
    required this.profile,
    required this.onComplete,
    super.key,
  });

  final UserProfile profile;
  final Future<void> Function(UserProfile profile) onComplete;

  @override
  State<OnboardingProfileFlow> createState() => _OnboardingProfileFlowState();
}

class _OnboardingProfileFlowState extends State<OnboardingProfileFlow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 등록')),
      body: ProfileEditorView(
        initialProfile: widget.profile,
        title: '처음 오셨네요. 내 취향부터 채워볼까요?',
        description:
            '닉네임과 사이즈 정보를 입력해두면 추천과 구매 흐름이 더 자연스럽게 이어져요.',
        submitLabel: '프로필 저장하고 시작하기',
        onSubmit: widget.onComplete,
      ),
    );
  }
}

class ProfileEditorView extends StatefulWidget {
  const ProfileEditorView({
    required this.initialProfile,
    required this.onSubmit,
    required this.title,
    required this.description,
    required this.submitLabel,
    super.key,
  });

  final UserProfile initialProfile;
  final Future<void> Function(UserProfile profile) onSubmit;
  final String title;
  final String description;
  final String submitLabel;

  @override
  State<ProfileEditorView> createState() => _ProfileEditorViewState();
}

class _ProfileEditorViewState extends State<ProfileEditorView> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _shoeSizeController;
  late final TextEditingController _topSizeController;
  late final TextEditingController _bottomSizeController;
  late final TextEditingController _heightController;
  late final TextEditingController _regionController;
  final Set<String> _preferredCategories = {};
  String _gender = '';

  static const _categories = ['구두', '로퍼', '부츠', '스니커즈', '의류'];
  static const _genders = ['남성', '여성', '선택 안 함'];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: widget.initialProfile.nickname,
    );
    _shoeSizeController = TextEditingController(
      text: widget.initialProfile.shoeSize,
    );
    _topSizeController = TextEditingController(
      text: widget.initialProfile.topSize,
    );
    _bottomSizeController = TextEditingController(
      text: widget.initialProfile.bottomSize,
    );
    _heightController = TextEditingController(
      text: widget.initialProfile.heightCm,
    );
    _regionController = TextEditingController(text: widget.initialProfile.region);
    _gender = widget.initialProfile.gender;
    _preferredCategories.addAll(widget.initialProfile.preferredCategories);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _shoeSizeController.dispose();
    _topSizeController.dispose();
    _bottomSizeController.dispose();
    _heightController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        Text(widget.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 10),
        Text(
          widget.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6F665E),
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: '기본 정보',
          child: Column(
            children: [
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '닉네임'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender.isEmpty ? null : _gender,
                decoration: const InputDecoration(labelText: '성별'),
                items: _genders
                    .map(
                      (gender) => DropdownMenuItem(
                        value: gender == '선택 안 함' ? '' : gender,
                        child: Text(gender),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _gender = value ?? ''),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: '키',
                  hintText: '예: 175',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _regionController,
                decoration: const InputDecoration(
                  labelText: '주 활동 지역',
                  hintText: '예: 서울 성수 / 분당',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '사이즈 정보',
          child: Column(
            children: [
              TextField(
                controller: _shoeSizeController,
                decoration: const InputDecoration(
                  labelText: '신발 사이즈',
                  hintText: '예: UK 8 / 270',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _topSizeController,
                decoration: const InputDecoration(
                  labelText: '상의 사이즈',
                  hintText: '예: 100 / M',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bottomSizeController,
                decoration: const InputDecoration(
                  labelText: '하의 사이즈',
                  hintText: '예: 30 / M',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '관심 카테고리',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in _categories)
                FilterChip(
                  label: Text(category),
                  selected: _preferredCategories.contains(category),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _preferredCategories.add(category);
                      } else {
                        _preferredCategories.remove(category);
                      }
                    });
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }

  void _submit() {
    widget.onSubmit(
      widget.initialProfile.copyWith(
        nickname: _nicknameController.text.trim(),
        gender: _gender.trim(),
        shoeSize: _shoeSizeController.text.trim(),
        topSize: _topSizeController.text.trim(),
        bottomSize: _bottomSizeController.text.trim(),
        heightCm: _heightController.text.trim(),
        region: _regionController.text.trim(),
        preferredCategories: _preferredCategories.toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7E1DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
