import "Model";
import "SimpleIndex";

contract DappModel is Model {
  SimpleIndex public nym_index;

  uint constant NYM = 0x6e796d;
  uint constant NAME = 0x6e616d65;
  uint constant DEVELOPER_ID = 0x646576656c6f7065725f6964;
  uint constant LOGO = 0x6c6f676f;

  uint constant ADDRESS = 0x61646472657373;
  uint constant DEVELOPER = 0x646576656c6f706572;
  uint constant SHORT_DESCRIPTION = 0x73686f72745f6465736372697074696f6e;
  uint constant LONG_DESCRIPTION = 0x6c6f6e675f6465736372697074696f6e;
  uint constant VERSION = 0x76657273696f6e;
  uint constant VERSIONS = 0x76657273696f6e73;
  uint constant VERSION_ID = 0x76657273696f6e5f6964; // "version_id"

  uint constant DAPPS = 0x6461707073;

  uint constant ATTRIBUTE = 0x617474726962757465; // "attribute"
  uint constant ATTRIBUTES = 0x61747472696275746573; // "attributes"

  function DappModel(SimpleIndex _nym_index) {
    if (address(_nym_index) == 0) {
      _nym_index = new SimpleIndex();
    }

    nym_index = _nym_index;

    keys.length = 6;
    keys[0][0] = NYM;
    keys[1][0] = NAME;
    keys[2][0] = DEVELOPER_ID;
    keys[3][0] = LOGO;
    keys[4][0] = SHORT_DESCRIPTION;
    keys[5][0] = LONG_DESCRIPTION;

    keys[0][1] = STRING;
    keys[1][1] = STRING;
    keys[2][1] = REFERENCE;
    keys[3][1] = STRING;
    keys[4][1] = STRING;
    keys[5][1] = STRING;

    associations.length = 2;
    associations[0][0] = VERSIONS;
    associations[0][1] = VERSION;
    associations[1][0] = ATTRIBUTES;
    associations[1][1] = ATTRIBUTE;

    read_only.length = 1;
    read_only[0][0] = VERSION_ID;
    read_only[0][1] = REFERENCE;
  }

  function create(uint[101][] attributes) returns(uint) {
    uint id = super.create(attributes);

    if (id != 0) {
      uint nym = attributes[0][1];
      nym_index.set(nym, id);

      Model developer_model = Model(coordinator.models(DEVELOPER));
      uint dev_id = attributes[2][1];
      developer_model.add_to_association(dev_id, DAPPS, id);
    }

    return id;
  }

  function validate(address sender, uint id, uint[101][] attributes) returns(bool) {
    // Require nym to be present, and fit into one data slot
    if (attributes[0][0] != 1) {
      ValidationError(NYM, "must be present");
      return false;
    }

    // Require display name to be present
    if (attributes[1][0] == 0) {
      ValidationError(NAME, "must be present");
      return false;
    }

    // Require developer ID to be present, and fit into one data slot
    if (attributes[2][0] != 1) {
      ValidationError(DEVELOPER_ID, "must be present");
      return false;
    }

    // Require logo to be present, and fit into one data slot
    if (attributes[3][0] != 1) {
      ValidationError(LOGO, "must be present");
      return false;
    }

    // Require short description to be present
    if (attributes[4][0] == 0) {
      ValidationError(SHORT_DESCRIPTION, "must be present");
      return false;
    }

    // Require long description to be present
    if (attributes[5][0] == 0) {
      ValidationError(LONG_DESCRIPTION, "must be present");
      return false;
    }

    // Require developer ID to be valid
    Model developer_model = Model(coordinator.models(DEVELOPER));
    EternalDB dev_db = EternalDB(developer_model.db());
    uint dev_id = attributes[2][1];
    if (dev_db.count() < dev_id) {
      ValidationError(DEVELOPER_ID, "is invalid");
      return false;
    }

    // Require sender to be the developer's address
    address developer = address(dev_db.get_entry(dev_id, ADDRESS, 0));
    if (developer != sender) {
      ValidationError(DEVELOPER_ID, "is not the sender of this transaction");
      return false;
    }

    if (id == 0) {
      // Create only

      // Require nym to be unique
      if (nym_index.lookup(attributes[0][1]) != 0) {
        ValidationError(NYM, "must be unique");
        return false;
      }

    } else {
      // Update only

      // Require developer_id to be unchanged
      uint current_dev_id = db.get_entry(id, DEVELOPER_ID, 0);
      if (current_dev_id != dev_id) {
        ValidationError(DEVELOPER_ID, "should be unchanged on update()");
        return false;
      }

      // Require nym to be unchanged
      if (nym_index.lookup(attributes[0][1]) != id) {
        ValidationError(NYM, "should be unchanged on update()");
        return false;
      }
    }

    return true;
  }

  function id_for_nym(uint nym) returns(uint) {
    return nym_index.lookup(nym);
  }

  function replace(address replacement) {
    if (msg.sender == address(coordinator)) {
      nym_index.transfer_ownership(replacement);
      super.replace(replacement);
    }
  }
}
