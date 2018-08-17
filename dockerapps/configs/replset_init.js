//
// mongo replication set init script
// create at 2018-08-16
//
// run cmd: mongo 127.0.0.1:27017 replset_init.js
//
printjson({"desc": "replication set init."});

var config = { _id: "rs0", members: [
  { _id: 0, host: "my-mongo-master:27017", priority: 1 },
  { _id: 1, host: "my-mongo-slave:27017", priority: 0.5 },
  { _id: 2, host: "my-mongo-arbiter:27017", arbiterOnly: true } ]
};
var err = rs.initiate(config);
if (err) {
  printjson(err);
}
//printjson(rs.status());
