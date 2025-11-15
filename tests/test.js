import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 20,                // 20 virtual users
  duration: '300s',        // run for 30 seconds
};

export default function () {
  http.get('http://demo-alb-1414112138.us-east-1.elb.amazonaws.com');
  sleep(1);
}