import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/Chat/chat_list_model.dart';
import '../../models/user.dart';

part 'new_chat_store.g.dart';

class NewChatStore = NewChatStoreBase with _$NewChatStore;

abstract class NewChatStoreBase with Store {
  @observable
  bool isLoading = false;

  final TextEditingController searchController = TextEditingController();
  static const int pageSize = 10;

  late PagingController<int, User> pagingController;

  @observable
  ObservableList<User> searchResults = ObservableList<User>();

  @action
  Future<List<User>> fetchPaginatedUsers(int skip) async {
    isLoading = true;
    try {
      final result = await apiService.getPaginatedUsers(skip, pageSize);
      return result;
    } catch (e) {
      toast(language.lblErrorFetchingData);
      return [];
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchUsers(int pageKey) async {
    try {
      final result = await fetchPaginatedUsers(pageKey);
      final isLastPage = result.length < pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(result);
      } else {
        pagingController.appendPage(result, pageKey + result.length);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @action
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      pagingController.refresh();
      return;
    }
    isLoading = true;
    try {
      final result = await apiService.searchUsers(query);
      if (result.isEmpty) {
        toast(language.lblNoUsersFound);
      }
      searchResults.clear();
      searchResults.addAll(result);
    } catch (e) {
      toast(language.lblErrorSearchingUsers);
    }
    isLoading = false;
  }

  @action
  void clearSearch() {
    searchResults.clear();
  }

  @action
  Future<Chat> createGroupChat(String groupName, List<int> userIds) async {
    isLoading = true;
    try {
      final chat = await apiService.createGroupChat(userIds,
          isGroupChat: true, groupName: groupName);
      //chats.insert(0, chat);
      return chat;
    } catch (e) {
      toast(language.lblFailedToCreateGroupChat);
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<Chat> initiateChat(int userId) async {
    isLoading = true;
    try {
      final chat = await apiService.createChat([userId]);
      //chats.insert(0, chat);
      return chat;
    } catch (e) {
      toast(language.lblFailedToInitiateChat);
      rethrow;
    } finally {
      isLoading = false;
    }
  }
}
