import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 50 },   // ramp to moderate load
    { duration: '5m', target: 100 },  // heavy load
    { duration: '10m', target: 150 }, // overload period
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'], // optional
  }
};

export default function () {
  http.get('http://demo-alb-1008157944.us-east-1.elb.amazonaws.com');
  sleep(0.1);
}
