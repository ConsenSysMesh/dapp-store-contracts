contract('ReviewModel', function(accounts) {
  var DEVELOPER = "0x646576656c6f706572";
  var DAPP = "0x64617070";
  var VERSION = "0x76657273696f6e";
  var REVIEW = "0x726576696577";

  before(function(done) {
    var review_model = ReviewModel.at(ReviewModel.deployed_address);
    var version_model = VersionModel.at(VersionModel.deployed_address);
    var developer_model = DeveloperModel.at(DeveloperModel.deployed_address);
    var dapp_model = DappModel.at(DappModel.deployed_address);
    var coordinator = ModelCoordinator.at(ModelCoordinator.deployed_address);

    developer_model.create([[0], [0], [0]]).
      then(function(dev_id) {return dapp_model.create([[1, 33], [1, 52], [1, 1], [1, 1], [1, 1], [1, 1]]) }).
      then(function() { return version_model.create([[1, 1], [0], [0], [0], [0], [0]]) }).
      then(function(tx) {
        done();
      }).catch(done);
  });

  it("requires a rating", function(done) {
    var review_model = ReviewModel.at(ReviewModel.deployed_address);

    review_model.validate.call(accounts[0], 0, [[1, 1], [1, VERSION], [0], [0], [0], [0]]).
      then(function(result) {
        assert.equal(result, false);
        done();
    }).catch(done);
  });

  it("requires rating to be between 1 and 5", function(done) {
    var review_model = ReviewModel.at(ReviewModel.deployed_address);

    review_model.validate.call(accounts[0], 0, [[1, 1], [1, VERSION], [1, 0], [0], [0], [0]]).
    then(function(result) { assert.equal(result, false); }).
    then(function() { return review_model.validate.call(accounts[0], 0, [[1, 1], [1, VERSION], [1, 6], [0], [0], [0]]) }).
      then(function(result) {
        assert.equal(result, false);
        done();
    }).catch(done);
  });

  it("updates review list on model", function(done) {
    var version_model = VersionModel.at(VersionModel.deployed_address);
    var review_model = ReviewModel.at(ReviewModel.deployed_address);

    var REVIEWS = "0x72657669657773";

    version_model.db.call().
      then(function(db_address) {
        var version_db = EternalDB.at(db_address);

        review_model.create([[1, 1], [1, VERSION], [1, 5], [0], [0], [0]]).
          then(function() { return version_db.get_length.call(1, REVIEWS) }).
          then(function(result) { assert.equal(result, 1) }).
          then(function() { return version_db.get_entry.call(1, REVIEWS, 0) }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    });
  });

  it("requires a real version", function(done) {
    var review_model = ReviewModel.at(ReviewModel.deployed_address);

    review_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);

        review_model.create([[1, 100], [1, VERSION], [1, 5], [0], [0], [0]]).
          then(function() { return db.count.call() }).
          then(function(result) {
            assert.equal(result, 1);
            done();
        }).catch(done);
    });
  });

  it("updates rating counts and total on model", function(done) {
    var version_model = VersionModel.at(VersionModel.deployed_address);
    var review_model = ReviewModel.at(ReviewModel.deployed_address);

    var RATING_COUNT = "0x726174696e675f636f756e74";
    var RATING_TOTAL = "0x726174696e675f746f74616c";

    version_model.db.call().
      then(function(db_address) {
        var version_db = EternalDB.at(db_address);

        review_model.create([[1, 1], [1, VERSION], [1, 3], [0], [0], [0]]).
          then(function() { return version_db.get_length.call(1, RATING_COUNT) }).
          then(function(result) { assert.equal(result, 1) }).
          then(function() { return version_db.get_length.call(1, RATING_TOTAL) }).
          then(function(result) { assert.equal(result, 1) }).
          then(function() { return version_db.get_entry.call(1, RATING_COUNT, 0) }).
          then(function(result) { assert.equal(result, 2) }).
          then(function() { return version_db.get_entry.call(1, RATING_TOTAL, 0) }).
          then(function(result) {
            assert.equal(result, 8);
            done();
        }).catch(done);
    });
  });

  it("automatically stores the address", function(done) {
    var review_model = ReviewModel.at(ReviewModel.deployed_address);
    var ADDRESS = "0x61646472657373";

    review_model.db.call().
      then(function(db_address) {
        var db = EternalDB.at(db_address);
        review_model.create([[1,1], [1, VERSION], [1, 5], [0], [0], [0]]).
          then(function() { return db.get_length.call(2, ADDRESS) }).
          then(function(result) { assert.equal(result, 1) }).
          then(function() { return db.get_entry.call(2, ADDRESS, 0) }).
          then(function(result) {
            assert.equal(web3.toHex(result), accounts[0]);
            done();
        }).catch(done);
    }).catch(done);
  });

  it("lets developers have reviews too", function(done) {
    var developer_model = DeveloperModel.deployed();
    var review_model = ReviewModel.deployed();

    var REVIEWS = "0x72657669657773";

    developer_model.db.call().
      then(function(db_address) {
        var developer_db = EternalDB.at(db_address);

        // NOTE: This depends on previous tests!!! 4th review created.
        review_model.create([[1, 1], [1, DEVELOPER], [1, 5], [0], [0], [0]]).
          then(function(tx) {return developer_db.get_length.call(1, REVIEWS) }).
          then(function(result) { assert.equal(result.valueOf(), 1) }).
          then(function() { return developer_db.get_entry.call(1, REVIEWS, 0) }).
          then(function(result) {
            assert.equal(result.valueOf(), 4);
            done();
        }).catch(done);
    });
  });
});
