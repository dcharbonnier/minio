var Minio = require('minio');
var settings = require('./minio.json');
var uuid = require('uuid');
var async = require('async');

var minioClient = [];
for (var i = 0; i < settings.public_ips.length; i++) {
    minioClient.push(new Minio.Client({
        endPoint: settings.public_ips[i],
        port: 9000,
        secure: false,
        accessKey: settings.access_key,
        secretKey: settings.secret_key
    }));
}
let file = '/root/randomfile';

minioClient[0].makeBucket('test', 'us-east-1', (err) => {
    if (err) {
        console.log("error creating the bucket", err);
    }
    async.map(minioClient, (client, callback) => {

        if (err) {
            console.log("error creating the bucket", err);
        }
        async.timesLimit(100, 5, (n, callback) => {
            client.fPutObject('test', uuid.v4(), file, 'application/octet-stream', (err) => {
                if (err) {
                    process.stdout.write('E');
                    //console.log(err);
                } else {
                    process.stdout.write('.');
                }
                callback();
            });
        }, (err) => {
            if (err) {
                console.log(err);
            }
            return callback();
        });

    }, (err) => {
        console.log(err);
    });
});
