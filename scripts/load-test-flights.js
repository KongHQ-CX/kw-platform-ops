import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';
import encoding from 'k6/encoding';

// Custom metrics
const errorRate = new Rate('errors');
const unauthorizedRate = new Rate('unauthorized');

// Test configuration
export const options = {
  stages: [
    { duration: '1m', target: 10 },    // Ramp up to 10 users over 1 minute
    { duration: '59m', target: 10 },   // Stay at 10 users for 59 minutes (1 hour total)
    { duration: '1m', target: 20 },    // Ramp up to 20 users over 1 minute
    { duration: '118m', target: 20 },  // Stay at 20 users for 118 minutes (~2 hours total)
    { duration: '1m', target: 15 },    // Ramp down to 15 users over 1 minute
    { duration: '58m', target: 15 },   // Stay at 15 users for 58 minutes (~1 hour)
    { duration: '2m', target: 0 },     // Ramp down to 0 users over 2 minutes
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
    errors: ['rate<0.1'],              // Error rate should be below 10%
  },
  insecureSkipTLSVerify: true,        // Skip certificate validation
};

const BASE_URL = 'https://ac2dd182909ad4dfebc2336dd8ccfe53-857b85b94eaf35a7.elb.eu-central-1.amazonaws.com/flights';
const USERNAME = __ENV.USERNAME;
const PASSWORD = __ENV.PASSWORD;

// Flight numbers to test
const FLIGHT_NUMBERS = [
  'KA0284',
  'KA0285',
  'KA0286',
  'KA0287',
  'KA0288',
  'KA0289',
  'KA0290',
  'KA0291',
  'KA0292',
  'KA0293',
];

// Create Basic Auth credentials
const credentials = `${USERNAME}:${PASSWORD}`;
const encodedCredentials = encoding.b64encode(credentials);

export default function () {
  // Randomly decide whether to send authenticated or unauthenticated request
  // 60% authenticated, 40% unauthenticated (resulting in 401s)
  const shouldAuthenticate = Math.random() < 0.6;
  
  // Randomly decide whether to query all flights or a specific flight
  // 50% all flights, 50% specific flight
  const querySpecificFlight = Math.random() < 0.5;
  
  let url = BASE_URL;
  if (querySpecificFlight) {
    const randomFlightNumber = FLIGHT_NUMBERS[Math.floor(Math.random() * FLIGHT_NUMBERS.length)];
    url = `${BASE_URL}/${randomFlightNumber}`;
  }
  
  let params = {
    headers: {},
  };

  if (shouldAuthenticate) {
    params.headers['Authorization'] = `Basic ${encodedCredentials}`;
  }

  const response = http.get(url, params);

  // Check response
  const isSuccess = check(response, {
    'status is 200 (authenticated)': (r) => shouldAuthenticate && r.status === 200,
    'status is 401 (unauthenticated)': (r) => !shouldAuthenticate && r.status === 401,
  });

  // Track metrics
  if (shouldAuthenticate && response.status !== 200) {
    errorRate.add(1);
  } else if (shouldAuthenticate) {
    errorRate.add(0);
  }

  if (!shouldAuthenticate) {
    unauthorizedRate.add(1);
  } else {
    unauthorizedRate.add(0);
  }

  // Log request details
  if (__ENV.DEBUG) {
    console.log(`Request: ${shouldAuthenticate ? 'Authenticated' : 'Unauthenticated'} - URL: ${url} - Status: ${response.status}`);
  }

  // Sleep for a random duration between 1 and 3 seconds to simulate natural user behavior
  sleep(Math.random() * 2 + 1);
}
