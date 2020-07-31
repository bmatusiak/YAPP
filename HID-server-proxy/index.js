

var hid_map_interface = {
    0: "/dev/hidg0",
    1: "/dev/hidg1",
    2: "/dev/hidg2",
    3: "/dev/hidg3"
};



var HID = require("node-hid"); //to dertermin hid interface file path

var spawn = require('child_process').spawn;

var usbDetect = require('usb-detection'); // to detect insert remove of hid device

usbDetect.startMonitoring();


function setup_dev_device(){
    var hid_vid = 5824;
    var hid_pid = 1158;
    usbDetect.on('add:' + hid_vid + ':' + hid_pid, function(device) { setupDevices() });
    usbDetect.on('remove:' + hid_vid + ':' + hid_pid, function(device) { destroyDevices(); });
    usbDetect.find(hid_vid, hid_pid, function(err, devices) {
        if (err) return console.log(err);
        if (devices[0]) {
            console.log("device found, doing device setup")
            setupDevices(hid_vid, hid_pid);
        }
    });
}


function setup_prod_device(){
    var hid_vid = 7504;
    var hid_pid = 24828;
    usbDetect.on('add:' + hid_vid + ':' + hid_pid, function(device) { setupDevices() });
    usbDetect.on('remove:' + hid_vid + ':' + hid_pid, function(device) { destroyDevices(); });
    usbDetect.find(hid_vid, hid_pid, function(err, devices) {
        if (err) return console.log(err);
        if (devices[0]) {
            console.log("device found, doing device setup")
            setupDevices(hid_vid, hid_pid);
        }
    });
}

setup_prod_device()
setup_dev_device()


// usbDetect.find(function(err, devices) {
//   console.log(err,devices) 
// });

var hid_ids_C = 0;
var savedHID = {};

function setupDevices(hid_vid, hid_pid) {
    var devices = HID.devices();

    for (var i in devices) {
        if (devices[i].vendorId == hid_vid && devices[i].productId == hid_pid) {
            var HID_DEVICE = devices[i];
            if (hid_map_interface[HID_DEVICE.interface]) {
                setup_proxy_cat_tee(hid_map_interface[HID_DEVICE.interface], HID_DEVICE.path);
            }

        }
    }

}

function destroyDevices() {
    for (var j in savedHID) {
        savedHID[j][0].kill("SIGINT");
        savedHID[j][1].kill("SIGINT");
    }
}


function setup_proxy_cat_tee(A, B) {
    var AC = spawn_cat(A);
    var AT = spawn_tee(A);

    savedHID[++hid_ids_C] = [AC, AT];

    var BC = spawn_cat(B);
    var BT = spawn_tee(B);

    savedHID[++hid_ids_C] = [BC, BT];

    AC.stdout.on("data", function(data) {
        console.log("Adata", data);

        BT.stdin.write(data);
    });

    BC.stdout.on("data", function(data) {
        console.log("Bdata", data);
        console.log("Bdata", data.toString("utf8"));

        AT.stdin.write(data);
    });

    console.log("Connected", A, "to", B);
}


function spawn_cat(readPath) {


    var childProcess = spawn('/bin/cat', [readPath], {
        cwd: __dirname
    });

    childProcess.stdout.on('data', (data) => {
        //console.log(data);
    });

    childProcess.stderr.on('data', (data) => {
        //console.log(data);
    });

    childProcess.on('close', (code) => {
        console.log(`cat ${readPath} exited with code ${code}`);
        // process.exit();
    });

    return childProcess;
}


function spawn_tee(writePath) {


    var childProcess = spawn('/usr/bin/tee', [writePath], {
        cwd: __dirname
    });

    childProcess.stdout.on('data', (data) => {
        //console.log(data);
    });

    childProcess.stderr.on('data', (data) => {
        //console.log(data);
    });

    childProcess.on('close', (code) => {
        console.log(`tee ${writePath} exited with code ${code}`);
        // process.exit();
    });

    return childProcess;
}

var nodeCleanup = require('node-cleanup');

nodeCleanup(function(exitCode, signal) {
    if (signal) {
        setTimeout(function() {
            console.log("cleaning up")
            destroyDevices();
            // calling process.exit() won't inform parent process of signal
            console.log("Bye");
            process.kill(process.pid, signal);
        }, 1);
        nodeCleanup.uninstall(); // don't call cleanup handler again
        return false;
    }

});
