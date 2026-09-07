export const COLORS = {
  primary: '#0984e3',
  primaryLight: '#74b9ff',
  primaryDark: '#0652DD',
  success: '#00b894',
  warning: '#fdcb6e',
  danger: '#d63031',
  background: '#f8f9fa',
  surface: '#ffffff',
  text: '#2d3436',
  textSecondary: '#636e72',
  textLight: '#b2bec3',
  border: '#dfe6e9',
  white: '#ffffff',
};

export const SPACING = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
};

export const RADIUS = {
  sm: 6,
  md: 10,
  lg: 16,
  full: 999,
};

export const SHADOWS = {
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 4,
    elevation: 3,
  },
  lg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.12,
    shadowRadius: 8,
    elevation: 6,
  },
};

export const TYPOGRAPHY = {
  title: {
    fontSize: 20,
    fontWeight: '700',
    color: COLORS.text,
  },
  subtitle: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.text,
  },
  body: {
    fontSize: 14,
    color: COLORS.text,
  },
  caption: {
    fontSize: 12,
    color: COLORS.textSecondary,
  },
  small: {
    fontSize: 10,
    color: COLORS.textLight,
  },
};
