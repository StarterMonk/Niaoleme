const request = require('supertest');
const express = require('express');
const { setupTestDB } = require('./setup');
const recordRoutes = require('../src/routes/records');
const authRoutes = require('../src/routes/auth');
const { errorHandler } = require('../src/middleware/errorHandler');

setupTestDB();

const app = express();
app.use(express.json());
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/records', recordRoutes);
app.use(errorHandler);

let token;

beforeEach(async () => {
  const res = await request(app)
    .post('/api/v1/auth/register')
    .send({
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
    });
  token = res.body.token;
});

describe('Records API', () => {
  describe('POST /api/v1/records', () => {
    it('should create a new record', async () => {
      const res = await request(app)
        .post('/api/v1/records')
        .set('Authorization', `Bearer ${token}`)
        .send({
          color: '浅黄',
          volume: '正常',
        });

      expect(res.status).toBe(201);
      expect(res.body.record).toHaveProperty('_id');
      expect(res.body.record.color).toBe('浅黄');
    });

    it('should return 400 for invalid color', async () => {
      const res = await request(app)
        .post('/api/v1/records')
        .set('Authorization', `Bearer ${token}`)
        .send({
          color: 'invalid-color',
        });

      expect(res.status).toBe(400);
    });

    it('should return 401 without token', async () => {
      const res = await request(app)
        .post('/api/v1/records')
        .send({
          color: '浅黄',
        });

      expect(res.status).toBe(401);
    });
  });

  describe('GET /api/v1/records', () => {
    it('should get user records', async () => {
      await request(app)
        .post('/api/v1/records')
        .set('Authorization', `Bearer ${token}`)
        .send({ color: '浅黄' });

      const res = await request(app)
        .get('/api/v1/records')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.records).toBeInstanceOf(Array);
      expect(res.body.records.length).toBe(1);
    });
  });

  describe('GET /api/v1/records/stats', () => {
    it('should get user stats', async () => {
      await request(app)
        .post('/api/v1/records')
        .set('Authorization', `Bearer ${token}`)
        .send({ color: '浅黄' });

      const res = await request(app)
        .get('/api/v1/records/stats')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('todayCount');
      expect(res.body).toHaveProperty('healthScore');
    });
  });

  describe('DELETE /api/v1/records/:id', () => {
    it('should delete a record', async () => {
      const createRes = await request(app)
        .post('/api/v1/records')
        .set('Authorization', `Bearer ${token}`)
        .send({ color: '浅黄' });

      const recordId = createRes.body.record._id;

      const res = await request(app)
        .delete(`/api/v1/records/${recordId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
    });

    it('should return 404 for non-existent record', async () => {
      const fakeId = '507f1f77bcf86cd799439011';
      const res = await request(app)
        .delete(`/api/v1/records/${fakeId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(404);
    });
  });
});
