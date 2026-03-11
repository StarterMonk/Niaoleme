# 尿了么 API 文档

## 概述

尿了么智能健康检测应用提供RESTful API接口，支持用户注册登录、健康检测、位置服务等功能。

## 基础信息

- **Base URL**: `https://api.niaolemo.com/api/v1`
- **认证方式**: JWT Bearer Token
- **数据格式**: JSON
- **字符编码**: UTF-8

## 通用响应格式

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {},
  "timestamp": "2024-01-30 10:00:00",
  "requestId": "uuid"
}
```

## 认证接口

### 用户注册

**POST** `/auth/register`

```json
{
  "username": "testuser",
  "password": "password123",
  "confirmPassword": "password123",
  "email": "test@example.com",
  "phone": "13800138000",
  "registerType": "USERNAME"
}
```

### 用户登录

**POST** `/auth/login`

```json
{
  "identifier": "testuser",
  "password": "password123",
  "loginType": "USERNAME"
}
```

**响应**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
    "tokenType": "Bearer",
    "expiresAt": "2024-01-30 11:00:00",
    "userInfo": {
      "uuid": "user-uuid",
      "username": "testuser",
      "nickname": "测试用户",
      "email": "test@example.com",
      "status": "ACTIVE"
    }
  }
}
```

### 检查用户名

**GET** `/auth/check-username?username=testuser`

### 检查邮箱

**GET** `/auth/check-email?email=test@example.com`

### 检查手机号

**GET** `/auth/check-phone?phone=13800138000`

## 健康检测接口

### 创建检测

**POST** `/health/tests`

```json
{
  "testType": "URINE",
  "sampleImageUrl": "https://example.com/image.jpg",
  "locationLatitude": 39.9042,
  "locationLongitude": 116.4074
}
```

### 获取检测列表

**GET** `/health/tests?page=0&size=10&sort=testDate,desc`

### 获取检测详情

**GET** `/health/tests/{testId}`

### 获取检测结果

**GET** `/health/tests/{testId}/results`

## 位置服务接口

### 搜索附近厕所

**GET** `/locations/toilets/nearby?lat=39.9042&lng=116.4074&radius=1000`

### 获取厕所详情

**GET** `/locations/toilets/{toiletId}`

### 添加厕所评价

**POST** `/locations/toilets/{toiletId}/reviews`

```json
{
  "rating": 5,
  "title": "很干净",
  "content": "设施齐全，环境很好",
  "cleanlinessRating": 5,
  "facilitiesRating": 4,
  "accessibilityRating": 5,
  "tags": ["干净", "设施齐全"]
}
```

## 用户管理接口

### 获取用户信息

**GET** `/users/profile`

### 更新用户信息

**PUT** `/users/profile`

```json
{
  "nickname": "新昵称",
  "gender": "M",
  "birthDate": "1990-01-01",
  "height": 175.5,
  "weight": 70.0
}
```

### 上传头像

**POST** `/users/avatar`

Content-Type: multipart/form-data

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |

## 认证说明

除了公开接口外，所有API都需要在请求头中携带JWT令牌：

```
Authorization: Bearer <access_token>
```

## 限流说明

- 注册接口：每IP每小时最多10次
- 登录接口：每IP每小时最多30次
- 检测接口：每用户每天最多10次
- 其他接口：每用户每分钟最多100次

## SDK和示例

### JavaScript/TypeScript

```javascript
const client = new NiaoLeMoClient({
  baseURL: 'https://api.niaolemo.com/api/v1',
  apiKey: 'your-api-key'
});

// 用户登录
const loginResult = await client.auth.login({
  identifier: 'username',
  password: 'password',
  loginType: 'USERNAME'
});

// 创建检测
const test = await client.health.createTest({
  testType: 'URINE',
  sampleImageUrl: 'image-url'
});
```

### Python

```python
from niaolemo_client import NiaoLeMoClient

client = NiaoLeMoClient(
    base_url='https://api.niaolemo.com/api/v1',
    api_key='your-api-key'
)

# 用户登录
login_result = client.auth.login(
    identifier='username',
    password='password',
    login_type='USERNAME'
)

# 创建检测
test = client.health.create_test(
    test_type='URINE',
    sample_image_url='image-url'
)
```

## 更新日志

### v1.0.0 (2024-01-30)
- 初始版本发布
- 支持用户注册登录
- 支持健康检测功能
- 支持位置服务功能