import "Model";
import "SimpleIndex";

contract UserModel is Model {
  SimpleIndex public address_index;

  uint constant LICENSE = 0x6c6963656e7365;
  uint constant LICENSES = 0x6c6963656e736573;

  function UserModel(SimpleIndex _address_index) {
    if (address(_address_index) == 0) {
      _address_index = new SimpleIndex();
    }

    address_index = _address_index;

    keys.length = 1;
    keys[0][0] = ADDRESS;
    keys[0][1] = ADDRESS;

    associations.length = 1;
    associations[0][0] = LICENSES;
    associations[0][1] = LICENSE;
  }

  function create(uint[101][] attributes) returns(uint) {
    uint id = super.create(attributes);

    if (id != 0) {
      uint _address = attributes[0][1];
      address_index.set(_address, id);
    }

    return id;
  }

  function validate(address sender, uint id, uint[101][] attributes) returns(bool) {
    if (id == 0) {
      // Create only

      // Require address to be unique
      if (address_index.lookup(attributes[0][1]) != 0) {
        ValidationError(ADDRESS, "must be unique");
        return false;
      }

    } else {
      // No updates.
      return false;
    }

    return true;
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
