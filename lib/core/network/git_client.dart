import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../../models/group.dart';
import '../../models/project.dart';
import '../../models/user.dart';
import '../../models/activity.dart';
import '../../models/branch.dart';
import '../../models/commit.dart';

class GitClient {
  Future<http.Response> _get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${Env.apiUrl}$path').replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'PRIVATE-TOKEN': Env.apiKey,
        'Accept': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<List<GitGroup>> getGroups() async {
    final res = await _get('/api/v4/groups', queryParams: {'per_page': '50'});
    final List<dynamic> jsonList = json.decode(res.body);
    return jsonList.map((e) => GitGroup.fromJson(e)).toList();
  }

  Future<List<GitProject>> getProjectsForGroup(int groupId) async {
    final res = await _get('/api/v4/groups/$groupId/projects', queryParams: {'per_page': '100', 'order_by': 'last_activity_at', 'sort': 'desc'});
    final List<dynamic> jsonList = json.decode(res.body);
    return jsonList.map((e) => GitProject.fromJson(e)).toList();
  }

  Future<List<GitUser>> getUsers() async {
    final res = await _get('/api/v4/users', queryParams: {'per_page': '100', 'active': 'true'});
    final List<dynamic> jsonList = json.decode(res.body);
    return jsonList.map((e) => GitUser.fromJson(e)).toList();
  }

  Future<List<GitProject>> getProjects({String orderBy = 'last_activity_at', String sort = 'desc', int perPage = 20}) async {
    final res = await _get('/api/v4/projects', queryParams: {
      'order_by': orderBy,
      'sort': sort,
      'per_page': perPage.toString(),
      'membership': 'true'
    });
    final List<dynamic> jsonList = json.decode(res.body);
    return jsonList.map((e) => GitProject.fromJson(e)).toList();
  }

  Future<GitProject> getProject(int id) async {
    final res = await _get('/api/v4/projects/$id');
    return GitProject.fromJson(json.decode(res.body));
  }

  Future<List<GitBranch>> getBranches(int projectId) async {
    final res = await _get('/api/v4/projects/$projectId/repository/branches', queryParams: {'per_page': '50'});
    final List<dynamic> jsonList = json.decode(res.body);
    return jsonList.map((e) => GitBranch.fromJson(e)).toList();
  }

  Future<List<GitCommit>> getCommits(int projectId, String branchName) async {
    final res = await _get('/api/v4/projects/$projectId/repository/commits', queryParams: {'ref_name': branchName, 'per_page': '50'});
    final List<dynamic> jsonList = json.decode(res.body);
    return jsonList.map((e) => GitCommit.fromJson(e)).toList();
  }

  Future<List<GitActivity>> getActivities({int perPage = 50, int? userId, DateTime? after}) async {
    final path = userId != null ? '/api/v4/users/$userId/events' : '/api/v4/events';
    
    final Map<String, String> params = {'per_page': perPage.toString()};
    if (after != null) {
      params['after'] = after.toIso8601String().split('T')[0];
    }

    final res = await _get(path, queryParams: params);
    final List<dynamic> jsonList = json.decode(res.body);
    return jsonList.map((e) => GitActivity.fromJson(e)).toList();
  }
}
