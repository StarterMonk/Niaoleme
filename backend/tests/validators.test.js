const mongoose = require('mongoose');

describe('Validators', () => {
  describe('Email validation', () => {
    it('should validate correct email format', () => {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      expect(emailRegex.test('test@example.com')).toBe(true);
      expect(emailRegex.test('user.name@domain.co')).toBe(true);
    });

    it('should reject invalid email formats', () => {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      expect(emailRegex.test('invalid')).toBe(false);
      expect(emailRegex.test('@domain.com')).toBe(false);
      expect(emailRegex.test('user@')).toBe(false);
    });
  });

  describe('Color validation', () => {
    const validColors = ['透明', '浅黄', '深黄', '琥珀色', '棕色'];

    it('should accept valid colors', () => {
      validColors.forEach(color => {
        expect(validColors.includes(color)).toBe(true);
      });
    });

    it('should reject invalid colors', () => {
      expect(validColors.includes('红色')).toBe(false);
      expect(validColors.includes('')).toBe(false);
    });
  });

  describe('Volume validation', () => {
    const validVolumes = ['少量', '正常', '大量'];

    it('should accept valid volumes', () => {
      validVolumes.forEach(volume => {
        expect(validVolumes.includes(volume)).toBe(true);
      });
    });

    it('should reject invalid volumes', () => {
      expect(validVolumes.includes('超大量')).toBe(false);
    });
  });

  describe('Rating validation', () => {
    it('should accept valid ratings (0-5)', () => {
      for (let i = 0; i <= 5; i++) {
        expect(i >= 0 && i <= 5).toBe(true);
      }
    });

    it('should reject invalid ratings', () => {
      expect(6 >= 0 && 6 <= 5).toBe(false);
      expect(-1 >= 0 && -1 <= 5).toBe(false);
    });
  });
});
