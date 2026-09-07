const mongoose = require('mongoose');

const urineRecordSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  color: { type: String, required: true, enum: ['透明', '浅黄', '深黄', '琥珀色', '棕色'] },
  volume: { type: String, enum: ['少量', '正常', '大量'] },
  latitude: { type: Number },
  longitude: { type: Number },
  locationName: { type: String, default: '' },
  isPublicToilet: { type: Boolean, default: false },
  hygieneRating: { type: Number, min: 0, max: 5, default: 0 },
  facilityRating: { type: Number, min: 0, max: 5, default: 0 },
  notes: { type: String, default: '' },
}, { timestamps: true });

urineRecordSchema.index({ user: 1, createdAt: -1 });

module.exports = mongoose.model('UrineRecord', urineRecordSchema);
