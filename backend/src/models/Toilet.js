const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  text: { type: String, required: true, maxlength: 500 },
}, { timestamps: true });

const toiletSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true, maxlength: 100 },
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  location: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], index: '2dsphere' },
  },
  hygieneSum: { type: Number, default: 0 },
  facilitySum: { type: Number, default: 0 },
  ratingCount: { type: Number, default: 0 },
  tags: [{ type: String, maxlength: 20 }],
  comments: [commentSchema],
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
}, { timestamps: true });

toiletSchema.index({ location: '2dsphere' });
toiletSchema.index({ latitude: 1, longitude: 1 });

module.exports = mongoose.model('Toilet', toiletSchema);
