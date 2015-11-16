contract('LicenseModel', function(accounts) {
  before(function(done) {
    var version_model = VersionModel.at(VersionModel.deployed_address);
    var developer_model = DeveloperModel.at(DeveloperModel.deployed_address);
    var dapp_model = DappModel.at(DappModel.deployed_address);
    var user_model = UserModel.at(UserModel.deployed_address);

    return developer_model.create([[0], [0], [0], [0]]).
      then(function() { return user_model.create([[1, accounts[0]]]) }).
      then(function() { return dapp_model.create([[1, 33], [1, 52], [1, 1], [1, 1], [1, 1], [1, 1]]) }).
      then(function() { return version_model.create([[1, 1], [0], [0], [0], [0], [0]]) }).
      then(function() {
        done();
      }).catch(done);
  });

  it("updates license list on version", function(done) {
    var version_model = VersionModel.deployed();
    var license_model = LicenseModel.deployed();

    var LICENSES = "0x6c6963656e736573";

    version_model.db.call().
      then(function(db_address) {
        var version_db = EternalDB.at(db_address);

        license_model.create([[1, 1]]).
          then(function() { return version_db.get_length.call(1, LICENSES) }).
          then(function(result) { assert.equal(result, 1) }).
          then(function() { return version_db.get_entry.call(1, LICENSES, 0) }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("updates license list on user", function(done) {
    var user_model = UserModel.at(UserModel.deployed_address);
    var license_model = LicenseModel.at(LicenseModel.deployed_address);

    var LICENSES = "0x6c6963656e736573";

    user_model.db.call().
      then(function(db_address) {
        var user_db = EternalDB.at(db_address);

        return user_db.get_length.call(1, LICENSES).
          then(function(result) { assert.equal(result, 1) }).
          then(function() { return user_db.get_entry.call(1, LICENSES, 0) }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    });
  });
});
