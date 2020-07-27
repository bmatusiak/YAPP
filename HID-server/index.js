var spawn = require('child_process').spawn;


doDown(()=>{
    doUp();
})


function doUp(done){
    var ls = spawn('/bin/bash', ['./usb_gadget_setup.sh', 'up'],{
        cwd : __dirname
    });
    
    ls.stdout.on('data', (data) => {
        console.log(`stdout: ${data}`);
    });
    
    ls.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
    });
    
    ls.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
        if(done) done();
    });
}



function doDown(done){
    var ls = spawn('/bin/bash', ['./usb_gadget_setup.sh', 'down'],{
        cwd : __dirname
    });
    
    ls.stdout.on('data', (data) => {
        console.log(`stdout: ${data}`);
    });
    
    ls.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
    });
    
    ls.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
        if(done) done();
    });
}