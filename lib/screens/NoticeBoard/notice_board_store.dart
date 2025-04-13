import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/notice_model.dart';

part 'notice_board_store.g.dart';

class NoticeBoardStore = NoticeBoardStoreBase with _$NoticeBoardStore;

abstract class NoticeBoardStoreBase with Store {
  @observable
  bool isLoading = false;

  final Box<NoticeModel> _noticeBox = Hive.box<NoticeModel>('noticeBoardBox');

  List<NoticeModel> notices = [];

  @action
  getNoticeBoard() async {
    if (_noticeBox.isNotEmpty) {
      notices.clear();
      notices.addAll(_noticeBox.values);
    }
    updateNoticeBoardInBackground();
  }

  Future<void> updateNoticeBoardInBackground() async {
    try {
      final apiNotices = await apiService.getNotices();

      final existingNoticeIds = _noticeBox.values.map((e) => e.id).toSet();
      int count = 0;
      for (var notice in apiNotices) {
        if (!existingNoticeIds.contains(notice.id)) {
          count++;
          _noticeBox.add(notice);
        }
      }

      if (count > 0) {
        // Update the in-memory list silently
        notices.clear();
        notices.addAll(_noticeBox.values);
        log('$count new notices found');
      } else {
        log('No new notices found');
      }
    } catch (e) {
      log(e.toString());
      // Silent failure; no loader is shown
    }
  }
}
