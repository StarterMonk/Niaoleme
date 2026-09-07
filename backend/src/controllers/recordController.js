const { validationResult } = require('express-validator');
const UrineRecord = require('../models/UrineRecord');
const { AppError, asyncHandler } = require('../middleware/errorHandler');

exports.create = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: errors.array()[0].msg } });
  }

  const { color, volume, latitude, longitude, locationName, isPublicToilet, hygieneRating, facilityRating, notes } = req.body;

  const record = await UrineRecord.create({
    user: req.user._id,
    color,
    volume,
    latitude,
    longitude,
    locationName,
    isPublicToilet,
    hygieneRating,
    facilityRating,
    notes,
  });

  res.status(201).json({ record });
});

exports.getAll = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: errors.array()[0].msg } });
  }

  const { page = 1, limit = 20 } = req.query;
  const records = await UrineRecord.find({ user: req.user._id })
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(parseInt(limit));

  const total = await UrineRecord.countDocuments({ user: req.user._id });

  res.json({ records, total, page: parseInt(page), pages: Math.ceil(total / limit) });
});

exports.getStats = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const now = new Date();
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

  const [todayRecords, weekRecords, totalRecords] = await Promise.all([
    UrineRecord.find({ user: userId, createdAt: { $gte: todayStart } }),
    UrineRecord.find({ user: userId, createdAt: { $gte: weekAgo } }),
    UrineRecord.countDocuments({ user: userId }),
  ]);

  const colorCounts = {};
  weekRecords.forEach(r => {
    colorCounts[r.color] = (colorCounts[r.color] || 0) + 1;
  });
  const dominantColor = Object.entries(colorCounts).sort((a, b) => b[1] - a[1])[0]?.[0] || '未知';

  const weeklyByDay = [];
  const days = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  for (let i = 6; i >= 0; i--) {
    const dayStart = new Date(now.getTime() - i * 24 * 60 * 60 * 1000);
    dayStart.setHours(0, 0, 0, 0);
    const dayEnd = new Date(dayStart.getTime() + 24 * 60 * 60 * 1000);
    const count = weekRecords.filter(r => r.createdAt >= dayStart && r.createdAt < dayEnd).length;
    weeklyByDay.push({ day: days[dayStart.getDay()], count });
  }

  let healthScore = 80;
  if (todayRecords.length >= 4 && todayRecords.length <= 8) healthScore += 5;
  if (dominantColor === '浅黄') healthScore += 10;
  if (todayRecords.length < 3 || todayRecords.length > 10) healthScore -= 10;
  if (dominantColor === '棕色' || dominantColor === '琥珀色') healthScore -= 5;
  healthScore = Math.max(0, Math.min(100, healthScore));

  res.json({
    todayCount: todayRecords.length,
    totalRecords,
    healthScore,
    dominantColor,
    weeklyByDay,
  });
});

exports.remove = asyncHandler(async (req, res) => {
  const record = await UrineRecord.findOneAndDelete({ _id: req.params.id, user: req.user._id });
  if (!record) {
    throw new AppError('记录不存在', 404, 'NOT_FOUND');
  }
  res.json({ deleted: true });
});
