import '../model/document_model.dart';

abstract class DocumentListViewContract {
  void onDocumentsLoaded(List<DocumentModel> documents);
  void onDocumentsError(String message);
  void showLoading();
  void hideLoading();
}