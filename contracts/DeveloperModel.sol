import "Model";
import "SimpleIndex";

contract DeveloperModel is Model {
  SimpleIndex public address_index;

  uint constant NAME = 0x6e616d65;
  uint constant LOGO = 0x6c6f676f;
  uint constant DESCRIPTION = 0x6465736372697074696f6e;

  uint constant ADDRESS = 0x61646472657373;
  uint constant DAPP = 0x64617070;
  uint constant DAPPS = 0x6461707073;
  uint constant ATTRIBUTE = 0x617474726962757465; // "attribute"
  uint constant ATTRIBUTES = 0x61747472696275746573; // "attributes"
  uint constant REVIEW = 0x726576696577; // "review"
  uint constant REVIEWS = 0x72657669657773; // "reviews"
  uint constant RATING_COUNT = 0x726174696e675f636f756e74;
  uint constant RATING_TOTAL = 0x726174696e675f746f74616c;

  function DeveloperModel(SimpleIndex _address_index) {
    if (address(_address_index) == 0) {
      _address_index = new SimpleIndex();
    }

    address_index = _address_index;

    keys.length = 3;

    // Names
    keys[0][0] = NAME;
    keys[1][0] = LOGO;
    keys[2][0] = DESCRIPTION;

    // Types
    keys[0][1] = STRING;
    keys[1][1] = STRING;
    keys[2][1] = STRING;

    associations.length = 3;
    associations[0][0] = DAPPS; // name of association
    associations[0][1] = DAPP;  // type
    associations[1][0] = ATTRIBUTES;
    associations[1][1] = ATTRIBUTE;
    associations[2][0] = REVIEWS;
    associations[2][1] = REVIEW;

    read_only.length = 3;
    read_only[0][0] = ADDRESS;
    read_only[1][0] = RATING_COUNT;
    read_only[2][0] = RATING_TOTAL;

    read_only[0][1] = ADDRESS;
    read_only[1][1] = INTEGER;
    read_only[2][1] = INTEGER;
  }

  function create(uint[101][] attributes) returns(uint) {
    uint id = super.create(attributes);

    if (id != 0) {
      db.add(id, RATING_COUNT, 0);
      db.add(id, RATING_TOTAL, 0);
      db.add(id, ADDRESS, uint(msg.sender));

      address_index.set(uint(msg.sender), id);
    }
  }

  function validate(address sender, uint id, uint[101][] attributes) returns(bool) {
    if (id == 0) {
      // Create only

      // Require address to be unique
      if (id_for_address(sender) != 0) {
        ValidationError(ADDRESS, "must be unique");
        return false;
      }

    } else {
      // Require sender to be original creator
      if (sender != address(db.get_entry(id, ADDRESS, 0))) {
        ValidationError(ADDRESS, "must be the owner of this entry");
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

  function id_for_address(address _address) returns(uint) {
    return address_index.lookup(uint(_address));
  }

  function replace(address replacement) {
    if (msg.sender == address(coordinator)) {
      address_index.transfer_ownership(replacement);
      super.replace(replacement);
    }
  }
}
