const express = require('express');
const router = express.Router();
const { body, query, param } = require('express-validator');
const { create, getAll, getStats, remove } = require('../controllers/recordController');
const auth = require('../middleware/auth');

router.use(auth);

router.post('/', [
  body('color').isIn(['透明', '浅黄', '深黄', '琥珀色', '棕色']).withMessage('颜色值无效'),
  body('volume').optional().isIn(['少量', '正常', '大量']).withMessage('尿量值无效'),
  body('latitude').optional().isFloat({ min: -90, max: 90 }).withMessage('纬度无效'),
  body('longitude').optional().isFloat({ min: -180, max: 180 }).withMessage('经度无效'),
  body('locationName').optional().isLength({ max: 200 }).withMessage('位置名称过长'),
  body('isPublicToilet').optional().isBoolean().withMessage('isPublicToilet 必须是布尔值'),
  body('hygieneRating').optional().isInt({ min: 0, max: 5 }).withMessage('卫生评分必须是0-5'),
  body('facilityRating').optional().isInt({ min: 0, max: 5 }).withMessage('设施评分必须是0-5'),
  body('notes').optional().isLength({ max: 500 }).withMessage('备注过长'),
], create);

router.get('/', [
  query('page').optional().isInt({ min: 1 }).withMessage('page 必须 >= 1'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('limit 必须在 1-100 之间'),
], getAll);

router.get('/stats', getStats);

router.delete('/:id', [
  param('id').isMongoId().withMessage('无效的记录ID'),
], remove);

module.exports = router;
