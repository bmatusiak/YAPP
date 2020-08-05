var pm2 = require('pm2');

pm2.connect(function(err) {
    if (err) {
        console.error(err);
        process.exit(2);
    }

    pm2.stop('DNS-server', (err, proc) => {
        if (err) console.log(err);

        pm2.restart('HID-setup', (err, proc) => {
            if (err) console.log(err);
            // else console.log(proc);
            console.log("Restarted HID-setup");

            var dhcp = require('dhcp');

            var s = dhcp.createServer({
                // System settings
                range: ["192.168.8.1", "192.168.8.200"], //["192.168.8.20","192.168.8.29"],
                forceOptions: ['hostname'], // Options that need to be sent, even if they were not requested
                //randomIP: true, // Get random new IP from pool instead of keeping one ip
                static: {
                    //"D6-97-24-CA-6F-67": "192.168.8.1"
                },

                // Option settings (there are MUCH more)
                netmask: '255.255.255.0',
                router: ['192.168.8.255'],
                dns: ["192.168.8.254"],
                domainName: "local.pi",
                hostname: "my.local.pi",
                broadcast: '192.168.8.255',
                server: '192.168.8.254', // This is us

            });

            s.on("error", function() {})

            s.listen(false, false, function() {
                console.log("DHCP Server Running");


                // setTimeout(function() {


                // pm2.start('HID-proxy', (err, proc) => {
                //     if (err) console.log(err);
                //     console.log("Started HID-proxy");
                //     // else console.log(proc);
                // });
                pm2.start('DNS-server', (err, proc) => {
                    if (err) console.log(err);
                    console.log("Started DNS-server");
                    // else console.log(proc);
                });


                // }, 5000);
            });

        });
    });
});
