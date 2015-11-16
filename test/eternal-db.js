contract('EternalDB', function(accounts) {
  it("should set the admin to its creator", function(done) {
    var db = EternalDB.at(EternalDB.deployed_address);

    db.admin.call()
      .then(function(result) {
        assert.equal(result, accounts[0]);
        done();
      }).catch(done);
  });

  it("should allow you to create a new entry", function(done) {
    var db = EternalDB.at(EternalDB.deployed_address);

    db.new_entry().
      then(function() { return db.count.call() }).
      then(function(result) {
        assert.equal(result, 1);
        done();
    }).catch(done);
  });

  it("should only allow admin to make changes", function(done) {
    var db = EternalDB.at(EternalDB.deployed_address);

    var id = 1;
    var key = 17;
    var value = 42;

    db.new_entry({from: accounts[1]}).
      then(function() { return db.count.call() }).
      then(function(result) { assert.equal(result, 1) }).
      then(function() { return db.add(id, key, value, {from: accounts[1]}) }).
      then(function() { return db.get_length.call(id, key) }).
      then(function(result) {
        assert.equal(result, 0);
        done();
    }).catch(done)
  });

  it("should allow storage of attributes", function(done) {
    var db = EternalDB.at(EternalDB.deployed_address);

    var id = 1;
    var key = 66;

    db.add(id, key, 11).
      then(function() { return db.add(id, key, 22) }).
      then(function() { return db.get_length.call(id, key) }).
      then(function(result) { assert.equal(result, 2) }).
      then(function() { return db.get_entry.call(id, key, 0) }).
      then(function(result) { assert.equal(result, 11) }).
      then(function() { return db.get_all.call(id, key) }).
      then(function(result) {
        assert.equal(result[0], 11);
        assert.equal(result[1], 22);
        done();
    }).catch(done)
  });

  it("should allow deletion of elements from array by index", function(done) {
    var db = EternalDB.at(EternalDB.deployed_address);

    var id = 1;
    var key = 63;

    db.add(id, key, 11).
      then(function() { return db.add(id, key, 22) }).
      then(function() { return db.add(id, key, 33) }).
      then(function() { return db.add(id, key, 44) }).
      then(function() { return db.delete_entry(id, key, 1) }).
      then(function() { return db.get_length.call(id, key) }).
      then(function(result) { assert.equal(result, 3) }).
      then(function() { return db.get_entry.call(id, key, 1) }).
      then(function(result) {
        assert.equal(result, 33);
        done();
    }).catch(done)
  })

  it("should allow admin to transfer ownership", function(done) {
    var db = EternalDB.at(EternalDB.deployed_address);

    db.transfer_ownership(accounts[1]).
      then(function() { return db.admin.call() }).
      then(function(result) {
        assert.equal(result, accounts[1]);
        done();
      }).catch(done);
  });
});
