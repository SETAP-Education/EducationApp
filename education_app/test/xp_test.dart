import 'package:flutter_test/flutter_test.dart';
import 'package:education_app/Quizzes/xpLogic.dart';

void main() {
  group('Rank function tests', () {
    test('getRank returns Bronze', () {
      expect(XpInterface.getRank(10), equals('Bronze')); // xp < 20
    });

    test('getRank returns Silver', () {
      expect(XpInterface.getRank(30), equals('Silver')); // 20 <= xp < 40
    });

    test('getRank returns Gold', () {
      expect(XpInterface.getRank(50), equals('Gold'));   // 40 <= xp < 60
    });

    test('getRank returns Platinum', () {
      expect(XpInterface.getRank(70), equals('Platinum')); // 60 <= xp < 80
    });

    test('getRank returns Emerald', () {
      expect(XpInterface.getRank(90), equals('Emerald'));  // 80 <= xp < 100
    });

    test('getRank returns Bronze for xp >= 100', () {
      expect(XpInterface.getRank(110), equals('Bronze')); // xp >= 100
    });
  });
}