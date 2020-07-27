module.exports = {

  apps: [{
    name: "DNS-server",
    script: 'index.js',
    watch: true,
    watch_options: {
      "followSymlinks": true
    }
  }]

};
