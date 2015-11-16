import "Model";
import "DualIndex";
import_headers "UserModel";

contract LicenseModel is Model {
  DualIndex public user_version_index;

  uint constant VERSION_ID = 0x76657273696f6e5f6964;

  uint constant VERSION = 0x76657273696f6e;
  uint constant LICENSES = 0x6c6963656e736573;
  uint constant USER = 0x75736572;
  uint constant USERS = 0x7573657273;
  uint constant USER_ID = 0x757365725f6964;

  function LicenseModel(DualIndex _user_version_index) {
    if (address(_user_version_index) == 0) {
      _user_version_index = new DualIndex();
    }

    user_version_index = _user_version_index;

    keys.length = 1;

    keys[0][0] = VERSION_ID;
    keys[0][1] = REFERENCE;

    read_only.length = 1;
    read_only[0][0] = USER_ID;
    read_only[0][1] = REFERENCE;
  }

  function create(uint[101][] attributes) returns(uint) {
    uint id = super.create(attributes);

    if (id != 0) {
      Model version_model = Model(coordinator.models(VERSION));
      uint version_id = attributes[0][1];
      version_model.add_to_association(version_id, LICENSES, id);

      UserModel user_model = UserModel(coordinator.models(USER));
      uint user_id = user_model.id_for_address(msg.sender);
      user_model.add_to_association(user_id, LICENSES, id);

      db.add(id, USER_ID, user_id);
      user_version_index.set(user_id, version_id, id);
    }

    return id;
  }

  function validate(address sender, uint id, uint[101][] attributes) returns(bool) {
    // Require version ID to be present, and fit into one data slot
    if (attributes[0][0] != 1) {
      ValidationError(VERSION_ID, "must be present");
      return false;
    }

    // Require version ID to be valid
    Model version_model = Model(coordinator.models(VERSION));
    EternalDB version_db = EternalDB(version_model.db());
    uint version_id = attributes[0][1];
    if (version_db.count() < version_id) {
      ValidationError(VERSION_ID, "invalid");
      return false;
    }

    UserModel user_model = UserModel(coordinator.models(USER));
    EternalDB user_db = EternalDB(user_model.db());
    uint user_id = user_model.id_for_address(sender);

    if (user_id == 0) {
      ValidationError(USER_ID, "doesn't exist for the sender address");
      return false;
    }

    // On create
    if (id == 0) {
      if (id_for_user_version(user_id, version_id) != 0) {
        ValidationError(USER_ID, "already has a license for this app");
        return false;
      }
    }

    // On update
    if (id != 0) {
      address user_address = address(user_db.get_entry(user_id, ADDRESS, 0));
      if (sender != user_address) {
        ValidationError(USER_ID, "is not the owner of this license");
        return false;
      }
    }

    return true;
  }

  function id_for_user_version(uint user_id, uint version_id) returns(uint) {
    return user_version_index.lookup(user_id, version_id);
  }

  function replace(address replacement) {
    if (msg.sender == address(coordinator)) {
      user_version_index.transfer_ownership(replacement);
      super.replace(replacement);
    }
  }
}
