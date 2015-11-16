import_headers "EternalDB";
import_headers "ModelCoordinator";

contract Model {
  EternalDB public db;
  uint[2][] public keys;
  uint[2][] public associations;
  uint[2][] public read_only;

  ModelCoordinator public coordinator;

  uint constant INTEGER = 0x696e7465676572;       // "integer"
  uint constant NUMBER = 0x6e756d626572;          // "number"
  uint constant ADDRESS = 0x61646472657373;       // "address"
  uint constant STRING = 0x737472696e67;          // "string"
  uint constant DATETIME = 0x6461746574696d65;    // "datetime"
  uint constant BOOL = 0x626f6f6c;                // "bool"
  uint constant INTEGER_ARRAY = 0x696e74656765725f6172726179; // "integer_array"
  uint constant STRING_ARRAY = 0x737472696e675f6172726179;    // "string_array"

  // References are a single pointer to another model, and that
  // model type is inferred by the key name. i.e., "version_id" -> VersionModel
  // References should not be confused with associations. Associations
  // have a "has_many" relationship whereas references point to a single instance.
  // Note: All reference keys must end in "_id".
  uint constant REFERENCE = 0x7265666572656e6365; // "reference"

  // Used to designate polymorphic associations on your models.
  // These are like references, except that the type is pulled from the
  // associated key which has the polymorphic type specified. Note the
  // id must come first in the keys list, and the type must follow
  // immediately after the id.
  uint constant POLYMORPHIC_REFERENCE = 0x706f6c796d6f72706869635f7265666572656e6365; // "polymorphic_reference"
  uint constant POLYMORPHIC_TYPE = 0x706f6c796d6f72706869635f74797065;                // "polymorphic_type"

  // Constants used for saving the created and last udpated blocks for each entry.
  // With these blocks, you can garner a lot of information about when the entry
  // was created and updated, and what happened during.
  uint constant CREATED_BLOCK = 0x637265617465645f626c6f636b; // "created_block"
  uint constant LAST_UPDATED_BLOCK = 0x6c6173745f757064617465645f626c6f636b; // "last_updated_block"

  uint constant OWNERS = 0x6f776e657273; // "owners"

  // Constant for marking a model entry as destroyed.
  uint constant DESTROYED = 0x64657374726f796564; // "destroyed"

  // Note: If you change the signature of any of these events,
  // the Javascript library needs to be updated accordingly.
  event Log(string reason);
  event Create(uint256 id);
  event Update(uint256 id);
  event Destroy(uint256 id);
  event ValidationError(uint256 indexed key, string reason);
  event GeneralError(string reason);

  function Model() {
    coordinator = ModelCoordinator(msg.sender);
  }

  function get_keys() constant returns(uint[2][]) {
    return keys;
  }

  function get_read_only_keys() constant returns(uint[2][]) {
    return read_only;
  }

  function get_associations() constant returns(uint[2][]) {
    return associations;
  }

  function get_default_keys() returns(uint[2][4]) {
    uint[2][4] memory defaults;

    defaults[0][0] = CREATED_BLOCK;
    defaults[0][1] = INTEGER;
    defaults[1][0] = LAST_UPDATED_BLOCK;
    defaults[1][1] = INTEGER;
    defaults[2][0] = OWNERS;
    defaults[2][1] = INTEGER_ARRAY; // Need to implement address arrays.
    defaults[3][0] = DESTROYED;
    defaults[3][1] = BOOL;

    return defaults;
  }

  function set_db(EternalDB _db) {
    if (address(db) == 0) {
      db = _db;
    }
  }

  function set_coordinator(ModelCoordinator _coordinator) {
    if (msg.sender == address(coordinator)) {
      coordinator = _coordinator;
    }
  }

  function create(uint[101][] attributes) returns(uint) {
    Log("create started");

    if (validate(msg.sender, 0, attributes) == true) {
      uint id = db.new_entry();

      for (uint i = 0; i < keys.length; i++) {
        for (uint j = 1; j <= attributes[i][0]; j++) {
          db.add(id, keys[i][0], attributes[i][j]);
        }
      }

      add_owner(id, msg.sender);
      db.add(id, DESTROYED, 0); // false
      db.add(id, CREATED_BLOCK, block.number);
      db.add(id, LAST_UPDATED_BLOCK, block.number);

      Create(id);

      return id;
    }
  }

  function update(uint id, uint[101][] attributes) returns(bool) {
    if (validate(msg.sender, id, attributes) == true) {

      for (uint i = 0; i < keys.length; i++) {
        db.clear(id, keys[i][0]);

        for (uint j = 1; j <= attributes[i][0]; j++) {
          db.add(id, keys[i][0], attributes[i][j]);
        }
      }

      db.clear(id, LAST_UPDATED_BLOCK);
      db.add(id, LAST_UPDATED_BLOCK, block.number);

      Update(id);

      return true;
    }
    return false;
  }

  function has_owners(uint id) constant returns(bool) {
    return db.get_length(id, OWNERS) != 0;
  }

  function is_owner(uint id, address to_check) constant returns(bool) {
    for (var i = 0; i < db.get_length(id, OWNERS); i++) {
      uint owner = db.get_entry(id, OWNERS, i);
      if (address(owner) == to_check) {
        return true;
      }
    }

    return false;
  }

  function add_owner(uint id, address owner) {
    if (has_owners(id) == false) {
      db.add(id, OWNERS, uint(owner));
      return;
    }

    if (is_owner(id, msg.sender)) {
      db.add(id, OWNERS, uint(owner));
    }
  }

  function destroy(uint id) {
    if (is_owner(id, msg.sender)) {
      db.clear(id, DESTROYED);
      db.add(id, DESTROYED, 1); // true
      Destroy(id);
    }
  }

  function is_destroyed(uint id) constant returns(bool) {
    return db.get_entry(id, DESTROYED, 0) == 1;
  }

  function validate(address sender, uint id, uint[101][] attributes) returns(bool) {
    return true;
  }

  function get_blocks_for(uint id) constant returns (uint[2]) {
    uint[2] memory blocks;
    blocks[0] = db.get_entry(id, CREATED_BLOCK, 0);
    blocks[1] = db.get_entry(id, LAST_UPDATED_BLOCK, 0);
    return blocks;
  }

  // Example:
  //
  // id               = id of this model (say, Dapp)
  // association_name = VERSIONS (association on Dapp that holds the association)
  // association_id   = id of Version to associate with
  //
  // The association_type is inferred from the name and will be used to ensure
  // the association is being set by the right model.
  function add_to_association(uint id, uint association_name, uint association_id) {
    if (db.has(id) == false) {
      return;
    }

    uint association_type = 0x0;

    // Find the type matching the association_name.
    for (uint i = 0; i < associations.length; i++) {
      if (associations[i][0] == association_name) {
        association_type = associations[i][1];
        break;
      }
    }

    // Only accept associations from the type specified.
    if (association_type == 0x0 || msg.sender != coordinator.models(association_type)) {
      return;
    }

    // Since we found the type with the right name, then can just go ahead and add the association.
    db.add(id, association_name, association_id);

    // Update timestamp
    db.clear(id, LAST_UPDATED_BLOCK);
    db.add(id, LAST_UPDATED_BLOCK, block.number);
  }

  function set_reference(uint id, uint reference_name, uint reference_id) {
    if (db.has(id) == false) {
      return;
    }

    // Here, we use a little "hack" to get the reference type. Since
    // the reference type is string data packed into an integer, we can
    // "pop off" the "_id" part of the reference name using division,
    // which will give us the type.
    // Note: 16777216 is 16 ^ 6, or 3 ASCII characters.
    uint reference_type = reference_name / 16777216;

    if (msg.sender != coordinator.models(reference_type)) {
      return;
    }

    // Since we found the type with the right name, then can just go ahead and set the reference.
    db.clear(id, reference_name);
    db.add(id, reference_name, reference_id);

    // Update timestamp
    db.clear(id, LAST_UPDATED_BLOCK);
    db.add(id, LAST_UPDATED_BLOCK, block.number);
  }

  /*function paged(uint start_id, uint page_size) constant returns(uint[102]) {
    uint[102] memory page;

    if (page_size > 100) {
      page_size = 100;
    }

    uint found = 0;
    uint next = 0;
    uint current_id = start_id;

    while(db.has(current_id) && found < 100) {
      if (is_destroyed(current_id) == false) {
        found += 1;
        next = current_id + 1;
        page[found+1] = current_id;
      }

      current_id += 1;
    }

    if (db.has(next) == false) {
      next = 0;
    }

    page[0] = found;
    page[1] = next;

    return page;
  }*/

  function replace(address replacement) {
    if (msg.sender == address(coordinator)) {
      db.transfer_ownership(replacement);
    }
  }
}
