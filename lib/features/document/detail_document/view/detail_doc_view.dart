import '../../document_list/model/document_model.dart';

abstract class DetailDocumentViewContract {
  void onDocumentLoaded(DocumentModel document, String notes);
  void onDocumentError(String message);
  void onDocumentDeleted(); // <-- baru: dipanggil setelah delete sukses
  void showLoading();
  void hideLoading();
}