const { validationResult } = require('express-validator');
const Toilet = require('../models/Toilet');
const { AppError, asyncHandler } = require('../middleware/errorHandler');

exports.create = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: errors.array()[0].msg } });
  }

  const { name, latitude, longitude, tags } = req.body;

  const toilet = await Toilet.create({
    name,
    location: { type: 'Point', coordinates: [longitude, latitude] },
    latitude,
    longitude,
    tags: tags || [],
    createdBy: req.user._id,
  });

  res.status(201).json({ toilet });
});

exports.getNearby = asyncHandler(async (req, res) => {
  const { latitude, longitude, maxDistance = 5000 } = req.query;

  let toilets;
  if (latitude && longitude) {
    toilets = await Toilet.find({
      location: {
        $nearSphere: {
          $geometry: { type: 'Point', coordinates: [parseFloat(longitude), parseFloat(latitude)] },
          $maxDistance: parseInt(maxDistance),
        },
      },
    }).limit(50);
  } else {
    toilets = await Toilet.find().sort({ createdAt: -1 }).limit(50);
  }

  const toiletList = toilets.map(t => ({
    id: t._id,
    name: t.name,
    latitude: t.latitude,
    longitude: t.longitude,
    hygiene: t.ratingCount > 0 ? (t.hygieneSum / t.ratingCount).toFixed(1) : '0.0',
    facility: t.ratingCount > 0 ? (t.facilitySum / t.ratingCount).toFixed(1) : '0.0',
    tags: t.tags,
    distance: t.distance || null,
    commentCount: t.comments.length,
    createdAt: t.createdAt,
  }));

  res.json({ toilets: toiletList });
});

exports.rate = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: errors.array()[0].msg } });
  }

  const { hygiene, facility, comment } = req.body;

  const toilet = await Toilet.findById(req.params.id);
  if (!toilet) {
    throw new AppError('厕所不存在', 404, 'NOT_FOUND');
  }

  if (hygiene) toilet.hygieneSum += hygiene;
  if (facility) toilet.facilitySum += facility;
  toilet.ratingCount += 1;

  if (comment) {
    toilet.comments.push({ user: req.user._id, text: comment });
  }

  await toilet.save();

  res.json({
    hygiene: (toilet.hygieneSum / toilet.ratingCount).toFixed(1),
    facility: (toilet.facilitySum / toilet.ratingCount).toFixed(1),
  });
});

exports.getDetail = asyncHandler(async (req, res) => {
  const toilet = await Toilet.findById(req.params.id).populate('comments.user', 'username');
  if (!toilet) {
    throw new AppError('厕所不存在', 404, 'NOT_FOUND');
  }

  res.json({
    id: toilet._id,
    name: toilet.name,
    latitude: toilet.latitude,
    longitude: toilet.longitude,
    hygiene: toilet.ratingCount > 0 ? (toilet.hygieneSum / toilet.ratingCount).toFixed(1) : '0.0',
    facility: toilet.ratingCount > 0 ? (toilet.facilitySum / toilet.ratingCount).toFixed(1) : '0.0',
    tags: toilet.tags,
    comments: toilet.comments.map(c => ({
      text: c.text,
      username: c.user?.username || '匿名',
      createdAt: c.createdAt,
    })),
    createdAt: toilet.createdAt,
  });
});
