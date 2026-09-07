const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { AppError } = require('./errorHandler');

const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (!token) {
      throw new AppError('请先登录', 401, 'AUTH_REQUIRED');
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id);
    if (!user) {
      throw new AppError('用户不存在', 401, 'AUTH_INVALID');
    }

    req.user = user;
    req.token = token;
    next();
  } catch (err) {
    if (err instanceof AppError) {
      return next(err);
    }
    if (err.name === 'JsonWebTokenError') {
      return next(new AppError('认证失败', 401, 'AUTH_INVALID'));
    }
    if (err.name === 'TokenExpiredError') {
      return next(new AppError('登录已过期', 401, 'AUTH_EXPIRED'));
    }
    next(new AppError('认证失败', 401, 'AUTH_INVALID'));
  }
};

module.exports = auth;
