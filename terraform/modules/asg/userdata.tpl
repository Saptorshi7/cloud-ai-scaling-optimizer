#!/bin/bash
yum update -y
amazon-linux-extras install nginx1
cat > /usr/share/nginx/html/index.html <<EOF
<html>
  <head><title>Demo Autoscaled Web</title></head>
  <body>
    <h1>${index_message}</h1>
    <p>Time: $(date)</p>
  </body>
</html>
EOF
systemctl enable nginx
systemctl start nginx
