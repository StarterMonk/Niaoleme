const express = require('express');
const router = express.Router();
const { body, query, param } = require('express-validator');
const { create, getNearby, rate, getDetail } = require('../controllers/toiletController');
const auth = require('../middleware/auth');

router.get('/', [
  query('latitude').optional().isFloat({ min: -90, max: 90 }),
  query('longitude').optional().isFloat({ min: -180, max: 180 }),
  query('maxDistance').optional().isInt({ min: 100, max: 50000 }),
], getNearby);

router.get('/:id', [
  param('id').isMongoId().withMessage('无效的厕所ID'),
], getDetail);

router.post('/', auth, [
  body('name').trim().isLength({ min: 1, max: 100 }).withMessage('厕所名称长度 1-100'),
  body('latitude').isFloat({ min: -90, max: 90 }).withMessage('纬度无效'),
  body('longitude').isFloat({ min: -180, max: 180 }).withMessage('经度无效'),
  body('tags').optional().isArray().withMessage('tags 必须是数组'),
  body('tags.*').optional().isString().isLength({ max: 20 }),
], create);

router.post('/:id/rate', auth, [
  param('id').isMongoId().withMessage('无效的厕所ID'),
  body('hygiene').optional().isInt({ min: 1, max: 5 }).withMessage('卫生评分 1-5'),
  body('facility').optional().isInt({ min: 1, max: 5 }).withMessage('设施评分 1-5'),
  body('comment').optional().isLength({ max: 500 }).withMessage('评价过长'),
], rate);

module.exports = router;
