import "Model";

contract VersionModel is Model {
  uint constant DAPP_ID = 0x646170705f6964;
  uint constant NUMBER = 0x6e756d626572;
  uint constant WHATS_NEW = 0x77686174735f6e6577;
  uint constant SCREENSHOTS = 0x73637265656e73686f7473;
  uint constant LOCATION = 0x6c6f636174696f6e;
  uint constant PRICE = 0x7072696365;

  uint constant DAPP = 0x64617070;
  uint constant DEVELOPER_ID = 0x646576656c6f7065725f6964;
  uint constant DEVELOPER = 0x646576656c6f706572;
  uint constant ADDRESS = 0x61646472657373;
  uint constant REVIEW = 0x726576696577;
  uint constant REVIEWS = 0x72657669657773;
  uint constant RATING_COUNT = 0x726174696e675f636f756e74;
  uint constant RATING_TOTAL = 0x726174696e675f746f74616c;
  uint constant LICENSE = 0x6c6963656e7365;
  uint constant LICENSES = 0x6c6963656e736573;

  uint constant VERSIONS = 0x76657273696f6e73; // "versions"
  uint constant VERSION_ID = 0x76657273696f6e5f6964; // "version_id"

  function VersionModel() {
    keys.length = 6;
    keys[0][0] = DAPP_ID;
    keys[1][0] = NUMBER;
    keys[2][0] = WHATS_NEW;
    keys[3][0] = SCREENSHOTS;
    keys[4][0] = LOCATION;
    keys[5][0] = PRICE;

    keys[0][1] = REFERENCE;
    keys[1][1] = STRING;
    keys[2][1] = STRING;
    keys[3][1] = STRING_ARRAY;
    keys[4][1] = STRING;
    keys[5][1] = INTEGER;

    associations.length = 2;
    associations[0][0] = REVIEWS;
    associations[0][1] = REVIEW;
    associations[1][0] = LICENSES;
    associations[1][1] = LICENSE;

    read_only.length = 2;
    read_only[0][0] = RATING_COUNT;
    read_only[1][0] = RATING_TOTAL;

    read_only[0][1] = INTEGER;
    read_only[1][1] = INTEGER;
  }

  function create(uint[101][] attributes) returns(uint) {
    uint id = super.create(attributes);

    if (id != 0) {
      uint dapp_id = attributes[0][1];

      Model dapp_model = Model(coordinator.models(DAPP));
      dapp_model.add_to_association(dapp_id, VERSIONS, id);
      dapp_model.set_reference(dapp_id, VERSION_ID, id);

      db.add(id, RATING_COUNT, 0);
      db.add(id, RATING_TOTAL, 0);
    }

    return id;
  }

  function validate(address sender, uint id, uint[101][] attributes) returns(bool) {
    // Require dapp ID to be present, and fit into one data slot
    if (attributes[0][0] != 1) {
      ValidationError(DAPP_ID, "must be present");
      return false;
    }

    // Require dapp ID to be valid
    Model dapp_model = Model(coordinator.models(DAPP));
    EternalDB dapp_db = EternalDB(dapp_model.db());
    uint dapp_id = attributes[0][1];
    if (dapp_db.count() < dapp_id) {
      ValidationError(DAPP_ID, "is invalid");
      return false;
    }

    // Require sender to be the developer's address
    Model developer_model = Model(coordinator.models(DEVELOPER));
    EternalDB dev_db = EternalDB(developer_model.db());
    uint dev_id = dapp_db.get_entry(dapp_id, DEVELOPER_ID, 0);
    address developer = address(dev_db.get_entry(dev_id, ADDRESS, 0));
    if (developer != sender) {
      ValidationError(DEVELOPER_ID, "is not the right sender");
      return false;
    }

    if (id != 0) {
      // Update only

      // Require dapp_id to be unchanged
      uint current_dapp_id = db.get_entry(id, DAPP_ID, 0);
      if (current_dapp_id != dapp_id) {
        ValidationError(DAPP_ID, "must not change on update()");
        return false;
      }
    }

    return true;
  }

  function add_rating(uint id, uint rating) {
    if (msg.sender == coordinator.models(REVIEW)) {
      uint current_count = db.get_entry(id, RATING_COUNT, 0);
      uint current_total = db.get_entry(id, RATING_TOTAL, 0);

      db.clear(id, RATING_COUNT);
      db.clear(id, RATING_TOTAL);

      db.add(id, RATING_COUNT, current_count + 1);
      db.add(id, RATING_TOTAL, current_total + rating);
    }
  }
}
