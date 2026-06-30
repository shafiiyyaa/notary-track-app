import '../../document_list/model/document_model.dart';

abstract class EditDocumentViewContract {
  void showLoading();
  void hideLoading();

  void onDocumentLoaded(DocumentModel document);

  void onUpdateSuccess();

  void onError(String message);
}