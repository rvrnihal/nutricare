import 'package:flutter_test/flutter_test.dart';
import 'package:nuticare/services/medicine_notification_service.dart';

void main() {
  group('MedicineNotificationService.parsePayload', () {
    test('returns open_medicine for empty payload', () {
      final action = MedicineNotificationService.parsePayload(null);
      expect(action.type, 'open_medicine');
      expect(action.medicineId, isNull);
    });

    test('parses JSON mark_taken payload', () {
      const payload = '{"action":"mark_taken","medicineId":"med123","medicineName":"Vitamin C"}';
      final action = MedicineNotificationService.parsePayload(payload);

      expect(action.type, 'mark_taken');
      expect(action.medicineId, 'med123');
      expect(action.medicineName, 'Vitamin C');
    });

    test('parses legacy mark_taken payload format', () {
      const payload = 'mark_taken:med42:Ibuprofen';
      final action = MedicineNotificationService.parsePayload(payload);

      expect(action.type, 'mark_taken');
      expect(action.medicineId, 'med42');
      expect(action.medicineName, 'Ibuprofen');
    });

    test('falls back to open_medicine for invalid payload', () {
      final action = MedicineNotificationService.parsePayload('not-a-json-payload');
      expect(action.type, 'open_medicine');
      expect(action.medicineId, isNull);
    });
  });
}
