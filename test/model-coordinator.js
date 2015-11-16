contract('ModelCoordinator', function(accounts) {
  it("lets admin replace models", function(done) {
    var old_user_model = UserModel.deployed();
    var model_coordinator = ModelCoordinator.deployed();

    var USER = "0x75736572";

    old_user_model.db.call().
    then(function(db_address) {
      var user_db = EternalDB.at(db_address);

      old_user_model.address_index.call().
      then(function(index_address) {
        UserModel.new(index_address).
        then(function(new_user_model) {
          model_coordinator.register(USER, new_user_model.address, db_address).
          then(function() { return user_db.count.call() }).
          then(function(result) { assert.equal(result, 0) }).
          then(function() { return new_user_model.create([[1, accounts[0]]]) }).
          then(function() { return new_user_model.create([[1, accounts[1]]]) }).
          then(function() { return old_user_model.create([[1, accounts[2]]]) }).
          then(function() { return user_db.count.call() }).
          then(function(result) {
            assert.equal(result, 2);
            done();
          }).catch(done);
        }).catch(done);
      }).catch(done);
    });
  });
});
