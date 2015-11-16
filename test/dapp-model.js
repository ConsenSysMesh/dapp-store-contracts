contract('DappModel', function(accounts) {

  before(function(done) {
    var developer_model = DeveloperModel.deployed()
    var dapp_model = DappModel.deployed();
    var coordinator = ModelCoordinator.deployed();

    var DEVELOPER = "0x646576656c6f706572";
    var DAPP = "0x64617070";

    developer_model.create([[0], [0], [0]], {from: accounts[0]}).
      then(function() { return developer_model.create([[0], [0], [0]], {from: accounts[2]}) }).
      then(function(tx) {
        done();
      }).catch(done);
  });

  it("lets you create a dapp", function(done) {
    var dapp_model = DappModel.at(DappModel.deployed_address);
    var NAME = "0x6e616d65";

    dapp_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);
        dapp_model.create([[1, 23], [1, 42], [1, 1], [1, 1], [1, 1], [1, 1]]).
          then(function() { return db.count.call() }).
          then(function(result) { assert.equal(result, 1); }).
          then(function() { return db.get_length.call(1, NAME) }).
          then(function(result) { assert.equal(result, 1) }).
          then(function() { return db.get_entry.call(1, NAME, 0) }).
          then(function(result) {
            assert.equal(result, 42);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("lets you update a dapp", function(done) {
    var dapp_model = DappModel.at(DappModel.deployed_address);
    var NAME = "0x6e616d65";

    dapp_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);
        dapp_model.update(1, [[1, 23], [1, 72], [1, 1], [1, 1], [1, 1], [1, 1]]).
          then(function() { return db.get_length.call(1, NAME) }).
          then(function(result) { assert.equal(result, 1) }).
          then(function() { return db.get_entry.call(1, NAME, 0) }).
          then(function(result) {
            assert.equal(result, 72);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("requires the developer_id to refer to something", function(done) {
    var dapp_model = DappModel.at(DappModel.deployed_address);

    dapp_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);
        dapp_model.create([[1, 24], [1, 42], [1, 100], [1, 1], [1, 1], [1, 1]]).
          then(function() { return db.count.call() }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("requires the sender to be the developer", function(done) {
    var dapp_model = DappModel.at(DappModel.deployed_address);

    dapp_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);
        dapp_model.create([[1, 25], [1, 42], [1, 1], [1, 1], [1, 1], [1, 1]], {from: accounts[1]}).
          then(function() { return db.count.call() }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("doesn't allow updates to change the developer", function(done) {
    var dapp_model = DappModel.at(DappModel.deployed_address);
    var DEVELOPER_ID = "0x646576656c6f7065725f6964";

    dapp_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);
        dapp_model.update(1, [[1, 23], [1, 72], [1, 2], [1, 1], [1, 1], [1, 1]]).
          then(function() { return db.get_entry.call(1, DEVELOPER_ID, 0) }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("requires a nym of 32 chars or less", function(done) {
    var dapp_model = DappModel.at(DappModel.deployed_address);

    dapp_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);

        dapp_model.create([[0], [1, 42], [1, 1], [1, 1], [1, 1], [1, 1]]).
          then(function() { return dapp_model.create([[2, 42, 42], [1, 42], [1, 1], [1, 1], [1, 1], [1, 1]]) }).
          then(function() { return db.count.call() }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("requires a unique nym", function(done) {
    var dapp_model = DappModel.at(DappModel.deployed_address);

    dapp_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);
        dapp_model.create([[1, 23], [1, 42], [1, 1], [1, 1], [1, 1], [1, 1]]).
          then(function() { return db.count.call() }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("doesn't allow updates to change the nym", function(done) {
    var dapp_model = DappModel.at(DappModel.deployed_address);
    var NYM = "0x6e796d";

    dapp_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);
        dapp_model.update(1, [[1, 13], [1, 72], [1, 1], [1, 1], [1, 1], [1, 1]]).
          then(function() { return db.get_entry.call(1, NYM, 0) }).
          then(function(result) {
            assert.equal(result, 23);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("updates dapp list on developer when new dapp is created", function(done) {
    var dapp_model = DappModel.deployed();
    var developer_model = DeveloperModel.deployed();

    var DAPPS = "0x6461707073";

    developer_model.db.call().
      then(function(db_address) {
        var dev_db = EternalDB.at(db_address);

        dapp_model.create([[1, 73], [1, 42], [1, 2], [1, 1], [1, 1], [1, 1]], {from: accounts[2]}).
          then(function() { return dev_db.get_length.call(2, DAPPS) }).
          then(function(result) { assert.equal(result.valueOf(), 1) }).
          then(function() { return dev_db.get_entry.call(2, DAPPS, 0) }).
          then(function(result) {
            assert.equal(result.valueOf(), 2);
            done();
        }).catch(done);
    });
  });

  it("returns a list of keys", function(done) {
    var dapp_model = DappModel.at(DappModel.deployed_address);
    var NAME = web3.toDecimal("0x6e616d65");
    var DEVELOPER_ID = web3.toDecimal("0x646576656c6f7065725f6964");

    dapp_model.get_keys.call().
      then(function(result) {
        assert.equal(result[1][0], NAME);
        assert.equal(result[2][0], DEVELOPER_ID);
        done();
    }).catch(done)
  });
});
