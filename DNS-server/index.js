console.log("started DNS-server ")


var dns = require('native-dns');
var server = dns.createServer();

server.on('request', function(request, response) {
    var r = request.question[0].name.split(".").reverse();

    if (
        r.shift() == "pi" &&
        r.shift() == "local" &&
        r.length >= 1 &&
        request.question[0].type == 1 &&
        request.question[0].class == 1
    ) {

        response.additional.push(dns.A({
            name: request.question[0].name,
            address: '192.168.8.254',
            ttl: 60,
        }));

        response.send();

        return;
    }

    // response.additional.push(dns.A({
    //     name: 'my.local.pi',
    //     address: '192.168.8.254',
    //     ttl: 60,
    // }));


    response.additional.push(dns.A({
        name: 'local.pi',
        address: '192.168.8.254',
        ttl: 60,
    }));

    response.send();
});

server.on('error', function(err, buff, req, res) {
    console.log(err.stack);
});

server.serve(53);
