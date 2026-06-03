import '../../document_list/model/document_model.dart';

abstract class DetailDocumentViewContract {
  void onDocumentLoaded(DocumentModel document, String notes);
  void onDocumentError(String message);
  void showLoading();
  void hideLoading();
}