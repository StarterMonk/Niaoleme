const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { register, login, getProfile } = require('../controllers/authController');
const auth = require('../middleware/auth');

const authLimiter = process.env.NODE_ENV !== 'test'
  ? require('../middleware/rateLimit').authLimiter
  : (req, res, next) => next();

router.post('/register', authLimiter, [
  body('username').trim().isLength({ min: 2, max: 30 }).withMessage('用户名长度 2-30'),
  body('email').isEmail().normalizeEmail().withMessage('请输入有效的邮箱'),
  body('password').isLength({ min: 6, max: 100 }).withMessage('密码长度 6-100'),
], register);

router.post('/login', authLimiter, [
  body('email').isEmail().normalizeEmail().withMessage('请输入有效的邮箱'),
  body('password').notEmpty().withMessage('请输入密码'),
], login);

router.get('/profile', auth, getProfile);

module.exports = router;
