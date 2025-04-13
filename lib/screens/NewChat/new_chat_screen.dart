import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/user.dart';
import '../../utils/app_widgets.dart';
import '../Chat/chat_screen.dart';
import 'new_chat_store.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _store = NewChatStore();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    _store.pagingController = PagingController(firstPageKey: 0);
    _store.pagingController.addPageRequestListener((pageKey) {
      _store.fetchUsers(pageKey);
    });

    _store.clearSearch();
  }

  @override
  void dispose() {
    _store.pagingController.dispose();
    _store.searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, language.lblNewChat),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Observer(
              builder: (_) {
                // Check if search results are available
                if (_store.searchResults.isNotEmpty) {
                  return _buildSearchResults();
                } else {
                  return _buildPaginatedUserList();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppTextField(
        controller: _store.searchController,
        textFieldType: TextFieldType.NAME,
        onChanged: (value) {
          if (value.length > 2) {
            _store.searchUsers(value);
          } else {
            _store.clearSearch();
          }
          _store.pagingController.refresh();
        },
        decoration: InputDecoration(
          hintText: '${language.lblSearchUsers}...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginatedUserList() {
    return PagedListView<int, User>(
      pagingController: _store.pagingController,
      builderDelegate: PagedChildBuilderDelegate<User>(
        noItemsFoundIndicatorBuilder: (_) =>
            Center(child: noDataWidget(message: language.lblNoUsersFound)),
        itemBuilder: (context, user, index) {
          return _buildUserListItem(user);
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _store.searchResults.length,
      itemBuilder: (context, index) {
        final user = _store.searchResults[index];
        return _buildUserListItem(user);
      },
    );
  }

  Widget _buildUserListItem(User user) {
    return ListTile(
      leading: userProfileWidget(user.initials,
          hideStatus: true, imageUrl: user.avatar),
      title:
          Text('${user.firstName} ${user.lastName}', style: primaryTextStyle()),
      subtitle: Text(user.email!, style: secondaryTextStyle(size: 12)),
      onTap: () async {
        final chat = await _store.initiateChat(user.id!);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chat: chat),
          ),
          (route) => route
              .isFirst, // Removes intermediate routes, keeps first (bottom nav)
        );
      },
    );
  }
}
