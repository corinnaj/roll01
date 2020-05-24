import 'package:roll01/models/roll.dart';
import 'package:test/test.dart';

void main() {
  test('single roll', () {
    Result result = Result.fromString('d20');
    expect(result.parts.length, 1);
    expect(result.parts[0], TypeMatcher<Roll>());
    expect((result.parts[0] as Roll).die, 20);
  });

  test('roll with modifier', () {
    Result result = Result.fromString('d8+3');
    expect(result.parts.length, 2);
    expect(result.parts[0], TypeMatcher<Roll>());
    expect((result.parts[0] as Roll).die, 8);
    expect(result.parts[1], TypeMatcher<Modifier>());
    expect((result.parts[1] as Modifier).modifier, 3);
  });

  test('roll with negative modifier', () {
    Result result = Result.fromString('d12-2');
    expect(result.parts.length, 2);
    expect(result.parts[0], TypeMatcher<Roll>());
    expect((result.parts[0] as Roll).die, 12);
    expect(result.parts[1], TypeMatcher<Modifier>());
    expect((result.parts[1] as Modifier).modifier, -2);
  });

  test('roll multiple dice roll', () {
    Result result = Result.fromString('2d10');
    expect(result.parts.length, 2);
    expect(result.parts[0], TypeMatcher<Roll>());
    expect((result.parts[0] as Roll).die, 10);
    expect(result.parts[1], TypeMatcher<Roll>());
    expect((result.parts[1] as Roll).die, 10);
  });

  test('roll complicated roll', () {
    Result result = Result.fromString('2d8+3+1d6-2');
    expect(result.parts.length, 5);
    expect(result.parts[0], TypeMatcher<Roll>());
    expect((result.parts[0] as Roll).die, 8);
    expect(result.parts[1], TypeMatcher<Roll>());
    expect((result.parts[1] as Roll).die, 8);
    expect(result.parts[2], TypeMatcher<Modifier>());
    expect((result.parts[2] as Modifier).modifier, 3);
    expect(result.parts[3], TypeMatcher<Roll>());
    expect((result.parts[3] as Roll).die, 6);
    expect(result.parts[4], TypeMatcher<Modifier>());
    expect((result.parts[4] as Modifier).modifier, -2);
  });

  test('roll with subtract', () {
    Result result = Result.fromString('d20+4-d4');
    expect(result.parts.length, 3);
    expect(result.parts[0], TypeMatcher<Roll>());
    expect((result.parts[0] as Roll).die, 20);
    expect(result.parts[1], TypeMatcher<Modifier>());
    expect((result.parts[1] as Modifier).modifier, 4);
    expect(result.parts[2], TypeMatcher<Roll>());
    expect((result.parts[2] as Roll).die, 4);
    expect((result.parts[2] as Roll).negated, true);
  });

  test('roll with advantage', () {
    Result result = Result.fromString('d20a');
    expect(result.parts.length, 1);
    expect(result.parts[0], TypeMatcher<DoubleRoll>());
    expect((result.parts[0] as DoubleRoll).advantage, true);
    expect((result.parts[0] as DoubleRoll).first, TypeMatcher<Roll>());
    expect((result.parts[0] as DoubleRoll).first.die, 20);
    expect((result.parts[0] as DoubleRoll).second, TypeMatcher<Roll>());
    expect((result.parts[0] as DoubleRoll).second.die, 20);
  });

  test('roll with disadvantage', () {
    Result result = Result.fromString('d20i+3');
    expect(result.parts.length, 2);
    expect(result.parts[0], TypeMatcher<DoubleRoll>());
    expect((result.parts[0] as DoubleRoll).advantage, false);
    expect((result.parts[0] as DoubleRoll).first, TypeMatcher<Roll>());
    expect((result.parts[0] as DoubleRoll).first.die, 20);
    expect((result.parts[0] as DoubleRoll).second, TypeMatcher<Roll>());
    expect((result.parts[0] as DoubleRoll).second.die, 20);
    expect(result.parts[1], TypeMatcher<Modifier>());
    expect((result.parts[1] as Modifier).modifier, 3);
  });
}
