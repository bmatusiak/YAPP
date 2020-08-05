var spawn = require('child_process').spawn;
var pm2 = require('pm2');


pm2.connect(function(err) {
    if (err) {
        console.error(err);
        process.exit(2);
    }

    pm2.stop('HID-proxy', (err, proc) => {
        if (err) console.log(err);
        doDown(() => {
            doUp(function() {
                pm2.start('HID-proxy', (err, proc) => {
                    if (err) console.log(err);
                    console.log("Started HID-proxy");
                    // else console.log(proc);
                    // pm2.disconnect();
                });
                // console.log("ready");
            });
        });
    });
});

function doUp(done) {
    var ls = spawn('/bin/bash', ['./usb_gadget_setup.sh', 'up'], {
        cwd: __dirname
    });

    ls.stdout.on('data', (data) => {
        console.log(`stdout: ${data}`);
    });

    ls.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
    });

    ls.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
        if (done) done();
    });
}



function doDown(done) {
    var ls = spawn('/bin/bash', ['./usb_gadget_setup.sh', 'down'], {
        cwd: __dirname
    });

    ls.stdout.on('data', (data) => {
        console.log(`stdout: ${data}`);
    });

    ls.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
    });

    ls.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
        if (done) done();
    });
}



var nodeCleanup = require('node-cleanup');

nodeCleanup(function(exitCode, signal) {
    if (signal) {
        setTimeout(function() {
            console.log("cleaning up");
            pm2.stop('HID-proxy', (err, proc) => {
                doDown(function() {
                    // calling process.exit() won't inform parent process of signal
                    console.log("Bye");
                    process.kill(process.pid, signal);
                });
            });
        }, 1);
        nodeCleanup.uninstall(); // don't call cleanup handler again
        return false;
    }

});
