import 'package:flutter_base/shared/models/user_profile_model.dart';

final UserProfileModel mockUser = UserProfileModel(
  id: 'user-001',
  email: 'demo@karaoke.local',
  displayName: 'Demo User',
  avatarUrl: 'https://i.pravatar.cc/200?img=1',
  bio: 'Yêu hát karaoke 🎤',
  isPremium: false,
  createdAt: DateTime(2025, 12, 1),
  songsSung: 247,
  totalMinutes: 1920,
  playlistCount: 8,
  contributionCount: 12,
);
