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
    group('Level function tests', () {
    test('get level returns 0 for level 0', () {
      expect(XpInterface.getLevel(0), equals(0));
    });
    test('get level returns 0 for 10', () {
      expect(XpInterface.getLevel(10), equals(0));
    });
    test('get level returns 1 for 20', () {
      expect(XpInterface.getLevel(20), equals(1));
    });
    test('get level returns 2 for 40', () {
      expect(XpInterface.getLevel(40), equals(2));
    });
    test('get level returns 3 for 60', () {
      expect(XpInterface.getLevel(60), equals(3));
    });
    test('get level returns 4 for 80', () {
      expect(XpInterface.getLevel(80), equals(4));
    });
    test('get level returns 40 for 20', () {
      expect(XpInterface.getLevel(110), equals(0));
    });
    });
    group('rank list function tests', () {
    test('rank list 0', () {
      expect(XpInterface.rankList[0], equals('Bronze'));
    });
    test('rank list 1', () {
      expect(XpInterface.rankList[1], equals('Silver'));
    });
    test('rank list 2', () {
      expect(XpInterface.rankList[2], equals('Gold'));
    });
    test('rank list 3', () {
      expect(XpInterface.rankList[3], equals('Platinum'));
    });
    test('rank list 4', () {
      expect(XpInterface.rankList[4], equals('Emerald'));
    });
  });
  });
}