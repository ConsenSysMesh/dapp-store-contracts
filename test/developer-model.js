contract('DeveloperModel', function(accounts) {
  it("automatically stores the address", function(done) {
    var developer_model = DeveloperModel.deployed();
    var ADDRESS = "0x61646472657373";

    developer_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);
        developer_model.create([[0], [0], [0]]).
          then(function() { return db.count.call() }).
          then(function(result) { assert.equal(result, 1); }).
          then(function() { return db.get_length.call(1, ADDRESS) }).
          then(function(result) { assert.equal(result, 1) }).
          then(function() { return db.get_entry.call(1, ADDRESS, 0) }).
          then(function(result) {
            assert.equal(web3.toHex(result), accounts[0]);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("doesn't let other users update a developer", function(done) {
    var developer_model = DeveloperModel.deployed();
    var NAME = web3.fromAscii("name");

    // NOTE: This relies on the previous test!

    developer_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);
        developer_model.update(1, [[1, 33], [0], [0]], {from: accounts[1]}).
          then(function() { return db.get_length.call(1, NAME) }).
          then(function(result) {
            assert.equal(result, 0);
            done();
        }).catch(done);
    }).catch(done);
  });
});
