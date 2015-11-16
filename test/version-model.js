contract('VersionModel', function(accounts) {
  before(function(done) {
    var version_model = VersionModel.at(VersionModel.deployed_address);
    var developer_model = DeveloperModel.at(DeveloperModel.deployed_address);
    var dapp_model = DappModel.at(DappModel.deployed_address);
    var coordinator = ModelCoordinator.at(ModelCoordinator.deployed_address);

    var DEVELOPER = "0x646576656c6f706572";
    var DAPP = "0x64617070";
    var VERSION = "0x76657273696f6e";

    developer_model.create([[0], [0], [0], [0]]).
      then(function() { return dapp_model.create([[1, 23], [1, 42], [1, 1], [1, 1], [1, 1], [1, 1]]) }).
      then(function() { return dapp_model.create([[1, 33], [1, 52], [1, 1], [1, 1], [1, 1], [1, 1]]) }).
      then(function(tx) {
        done();
      }).catch(done);
  });

  it("updates version list on dapp", function(done) {
    var version_model = VersionModel.at(VersionModel.deployed_address);
    var dapp_model = DappModel.at(DappModel.deployed_address);

    var VERSIONS = "0x76657273696f6e73";
    var NAME = "0x6e616d65";

    dapp_model.db.call().
      then(function(db_address) {
        var dapp_db = EternalDB.at(db_address);

        version_model.create([[1, 1], [0], [0], [0], [0], [0]]).
          then(function() { return dapp_db.get_length.call(1, VERSIONS) }).
          then(function(result) { assert.equal(result, 1) }).
          then(function() { return dapp_db.get_entry.call(1, VERSIONS, 0) }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("requires a real dapp", function(done) {
    var version_model = VersionModel.at(VersionModel.deployed_address);

    version_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);

        version_model.create([[1, 100], [0], [0], [0], [0], [0]]).
          then(function() { return db.count.call() }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("only allows dapp developer to create version", function(done) {
    var version_model = VersionModel.at(VersionModel.deployed_address);

    version_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);

        version_model.create([[1, 1], [0], [0], [0], [0], [0]], {from: accounts[2]}).
          then(function() { return db.count.call() }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("doesn't allow dapp_id to be changed", function(done) {
    var version_model = VersionModel.at(VersionModel.deployed_address);
    var DAPP_ID = "0x646170705f6964";

    version_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);

        version_model.update(1, [[1, 2], [0], [0], [0], [0], [0]]).
          then(function() { return db.get_entry.call(1, DAPP_ID, 0) }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    }).catch(done);
  });
});
