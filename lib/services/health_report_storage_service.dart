import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:nuticare/models/health_report_model.dart';

/// Service for managing health report uploads and storage
class HealthReportStorageService {
  static final _storage = FirebaseStorage.instance;
  static final _firestore = FirebaseFirestore.instance;
  static const String _reportsCollection = 'healthReports';
  static const _uuid = Uuid();

  /// Upload health report file to Firebase Storage
  static Future<String?> uploadReportFile(
    String filePath, {
    required void Function(double progress) onProgress,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      final file = File(filePath);
      if (!file.existsSync()) throw 'File does not exist';

      final fileName = file.path.split('/').last;
      final fileSize = file.lengthSync();

      // Limit file size to 10MB
      if (fileSize > 10 * 1024 * 1024) {
        throw 'File too large. Maximum 10MB allowed.';
      }

      final reportId = _uuid.v4();
      final uploadTask = _storage
          .ref()
          .child('users/${user.uid}/health_reports/$reportId/$fileName')
          .putFile(file);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        onProgress(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }

  /// Save health report metadata to Firestore
  static Future<void> saveReportMetadata(
    String reportId,
    String fileUrl,
    String fileName,
    MedicalValues values, {
    DateTime? reportDate,
    String? notes,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      await _firestore
          .collection(_reportsCollection)
          .doc(reportId)
          .set({
        'userId': user.uid,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'uploadedAt': FieldValue.serverTimestamp(),
        'reportDate': reportDate,
        'values': values.toJson(),
        'analysisNotes': notes,
      });
    } catch (e) {
      debugPrint('Error saving report metadata: $e');
      rethrow;
    }
  }

  /// Get all health reports for current user
  static Future<List<HealthReport>> getUserHealthReports() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection(_reportsCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HealthReport(
                id: doc.id,
                userId: user.uid,
                fileUrl: doc['fileUrl'] as String,
                fileName: doc['fileName'] as String,
                uploadedAt: (doc['uploadedAt'] as Timestamp).toDate(),
                reportDate: doc['reportDate'] != null
                    ? (doc['reportDate'] as Timestamp).toDate()
                    : null,
                values: MedicalValues.fromJson(doc['values'] as Map<String, dynamic>),
                analysisNotes: doc['analysisNotes'] as String?,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching health reports: $e');
      return [];
    }
  }

  /// Get latest health report
  static Future<HealthReport?> getLatestHealthReport() async {
    try {
      final reports = await getUserHealthReports();
      return reports.isNotEmpty ? reports.first : null;
    } catch (e) {
      debugPrint('Error fetching latest report: $e');
      return null;
    }
  }

  /// Delete a health report
  static Future<void> deleteHealthReport(String reportId, String fileUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      // Delete from Firestore
      await _firestore
          .collection(_reportsCollection)
          .doc(reportId)
          .delete();

      // Delete from Storage
      try {
        final ref = FirebaseStorage.instance.refFromURL(fileUrl);
        await ref.delete();
      } catch (e) {
        debugPrint('Error deleting file from storage: $e');
      }
    } catch (e) {
      debugPrint('Error deleting health report: $e');
      rethrow;
    }
  }

  /// Save health analysis results
  static Future<void> saveHealthAnalysis(
    String reportId,
    HealthAnalysis analysis,
  ) async {
    try {
      await _firestore
          .collection(_reportsCollection)
          .doc(reportId)
          .update({
        'analysis': analysis.toJson(),
        'analysisDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving analysis: $e');
      rethrow;
    }
  }

  /// Get health analysis for a report
  static Future<HealthAnalysis?> getHealthAnalysis(String reportId) async {
    try {
      final doc =
          await _firestore.collection(_reportsCollection).doc(reportId).get();

      if (doc.exists && doc['analysis'] != null) {
        return HealthAnalysis.fromJson(doc['analysis'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching analysis: $e');
      return null;
    }
  }

  /// Check if user has uploaded reports
  static Future<bool> hasHealthReports() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final snapshot = await _firestore
          .collection(_reportsCollection)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking health reports: $e');
      return false;
    }
  }

  /// Generate secure PDF download link (if needed)
  static Future<String?> generateDownloadLink(String reportId) async {
    try {
      final doc =
          await _firestore.collection(_reportsCollection).doc(reportId).get();

      if (doc.exists) {
        final fileUrl = doc['fileUrl'] as String;
        return fileUrl;
      }

      return null;
    } catch (e) {
      debugPrint('Error generating download link: $e');
      return null;
    }
  }
}
