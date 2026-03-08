import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hasthaartha_app/localdb/repo/local_repo.dart';

final localRepoProvider = Provider<LocalRepo>((ref) {
  return LocalRepo();
});