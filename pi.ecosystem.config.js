module.exports = {

  apps: [{
    name: "c9sdk",
    script: 'server.js',
    cwd: '/home/pi/c9sdk',
    args: "-l 0.0.0.0 -p 8080 -a : -w /home/pi/workspace --packed"
  }]
  
};
