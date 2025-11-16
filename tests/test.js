import http from "k6/http";
import { sleep } from "k6";

export const options = {
  vus: 100,
  duration: "15m",
};

export default function () {
  // Random burst size 1–5
  const burst = Math.floor(Math.random() * 5) + 1;

  for (let i = 0; i < burst; i++) {
    http.get("http://demo-alb-1642533398.us-east-1.elb.amazonaws.com");
  }

  // Random short pause 50ms–300ms
  sleep(Math.random() * 0.25 + 0.05);
}
