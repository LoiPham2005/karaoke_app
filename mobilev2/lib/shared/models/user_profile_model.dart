class UserProfileModel {

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt, this.avatarUrl,
    this.bio,
    this.isPremium = false,
    this.songsSung = 0,
    this.totalMinutes = 0,
    this.playlistCount = 0,
    this.contributionCount = 0,
  });
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isPremium;
  final DateTime createdAt;
  final int songsSung;
  final int totalMinutes;
  final int playlistCount;
  final int contributionCount;
}
