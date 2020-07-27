module.exports = {
  
  apps : [{
    name: "DHCP-server",
    cwd: '/home/pi/YAPP/DHCP-server',
    script: 'index.js'
  },{
    name: "DNS-server",
    cwd: '/home/pi/YAPP/DNS-server',
    script: 'index.js'
  },{
    name: "HID-setup",
    cwd: '/home/pi/YAPP/HID-server',
    script: 'index.js',
    autorestart : false
  },{
    name: "HID-server-proxy",
    cwd: '/home/pi/YAPP/HID-server-proxy',
    script: 'index.js'
  }]
  
};
