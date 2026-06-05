require('dotenv').config({ path: __dirname + '/../.env' });
const http = require('http');

function request(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const opts = {
      hostname: 'localhost', port: 3000,
      path: '/api' + path, method,
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: 'Bearer ' + token } : {}),
        ...(data ? { 'Content-Length': Buffer.byteLength(data) } : {})
      }
    };
    const req = http.request(opts, res => {
      let raw = '';
      res.on('data', c => raw += c);
      res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(raw) }));
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

const { spawn } = require('child_process');
const server = spawn('node', ['index.js'], { cwd: __dirname + '/..' });

server.stdout.on('data', async (d) => {
  if (d.toString().includes('running on port 3000')) {
    try {
      console.log('\n--- Running RBAC Automated Tests ---');
      
      // 1. Unauthenticated Request
      let r = await request('GET', '/users', null, null);
      console.log(`[TEST] Unauthenticated request to /users -> Status: ${r.status} (Expected 401) ${r.status === 401 ? '✅' : '❌'}`);

      // 2. Invalid Token Request
      r = await request('GET', '/users', null, 'invalid.jwt.token');
      console.log(`[TEST] Invalid token to /users -> Status: ${r.status} (Expected 401) ${r.status === 401 ? '✅' : '❌'}`);

      // 3. Admin Login & Access
      r = await request('POST', '/auth/login', { email: process.env.ADMIN_EMAIL, password: process.env.ADMIN_PASSWORD });
      const adminToken = r.body.token;
      
      r = await request('GET', '/users', null, adminToken);
      console.log(`[TEST] Admin request to /users -> Status: ${r.status} (Expected 200) ${r.status === 200 ? '✅' : '❌'}`);

      // 4. Create and Login as FieldStaff
      const fsEmail = `fs_${Date.now()}@test.com`;
      await request('POST', '/auth/register', { username: `fs_${Date.now()}`, email: fsEmail, password: 'password123' });
      r = await request('POST', '/auth/login', { email: fsEmail, password: 'password123' });
      const fsToken = r.body.token;

      // 5. FieldStaff accessing Admin Endpoint
      r = await request('GET', '/users', null, fsToken);
      console.log(`[TEST] FieldStaff request to /users (Admin endpoint) -> Status: ${r.status} (Expected 403) ${r.status === 403 ? '✅' : '❌'}`);

      console.log('\n--- RBAC Tests Complete ---');
      server.kill();
    } catch (e) {
      console.error('Test script error:', e);
      server.kill();
    }
  }
});
