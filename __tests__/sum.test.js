
const { sum, sumab } = require('../src/sum');

test('adds 1 + 2 to equal 3', () => {
  expect(sum(1, 2)).toBe(3);
});

test('adds 3 + 5 to equal 8 using sumab', () => {
  expect(sumab(3, 5)).toBe(8);
});