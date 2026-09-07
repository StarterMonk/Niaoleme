export const validators = {
  email: (value) => {
    if (!value) return '请输入邮箱';
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(value) ? null : '邮箱格式不正确';
  },

  password: (value) => {
    if (!value) return '请输入密码';
    if (value.length < 6) return '密码至少6位';
    if (value.length > 100) return '密码过长';
    return null;
  },

  username: (value) => {
    if (!value) return '请输入用户名';
    if (value.length < 2) return '用户名至少2个字符';
    if (value.length > 30) return '用户名最多30个字符';
    return null;
  },

  color: (value) => {
    const valid = ['透明', '浅黄', '深黄', '琥珀色', '棕色'];
    return valid.includes(value) ? null : '请选择有效的颜色';
  },

  volume: (value) => {
    if (!value) return null;
    const valid = ['少量', '正常', '大量'];
    return valid.includes(value) ? null : '请选择有效的尿量';
  },

  latitude: (value) => {
    if (value === undefined || value === null) return null;
    const n = parseFloat(value);
    return n >= -90 && n <= 90 ? null : '纬度无效';
  },

  longitude: (value) => {
    if (value === undefined || value === null) return null;
    const n = parseFloat(value);
    return n >= -180 && n <= 180 ? null : '经度无效';
  },

  rating: (value) => {
    if (value === undefined || value === null) return null;
    const n = parseInt(value);
    return n >= 0 && n <= 5 ? null : '评分必须在 0-5 之间';
  },

  required: (value, fieldName) => {
    return value ? null : `请输入${fieldName}`;
  },

  maxLength: (value, max, fieldName) => {
    if (!value) return null;
    return value.length <= max ? null : `${fieldName}最多${max}个字符`;
  },
};

export const validate = (data, rules) => {
  const errors = {};
  for (const [field, fieldRules] of Object.entries(rules)) {
    for (const rule of fieldRules) {
      const error = rule(data[field]);
      if (error) {
        errors[field] = error;
        break;
      }
    }
  }
  return { valid: Object.keys(errors).length === 0, errors };
};
