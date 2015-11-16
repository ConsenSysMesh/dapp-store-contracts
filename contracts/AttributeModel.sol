import "Model";

contract AttributeModel is Model {
  uint constant KEY = 0x6b6579; // "key"
  uint constant VALUE = 0x76616c7565; // "value"
  uint constant MODEL_ID = 0x6d6f64656c5f6964; // "model_id"
  uint constant MODEL_TYPE = 0x6d6f64656c5f74797065; // "model_type"

  uint constant DAPP = 0x64617070; // "dapp"
  uint constant DEVELOPER = 0x646576656c6f706572; // "developer"

  uint constant ATTRIBUTES = 0x61747472696275746573; // "attributes"

  function AttributeModel() {
    keys.length = 4;
    keys[0][0] = KEY;
    keys[1][0] = VALUE;
    keys[2][0] = MODEL_ID;
    keys[3][0] = MODEL_TYPE;

    keys[0][1] = STRING;
    keys[1][1] = STRING;
    keys[2][1] = POLYMORPHIC_REFERENCE;
    keys[3][1] = POLYMORPHIC_TYPE;
  }

  function create(uint[101][] attributes) returns(uint) {
    uint id = super.create(attributes);

    if (id != 0) {
      uint model_id = attributes[2][1];
      uint model_type = attributes[3][1];
      Model model = Model(coordinator.models(model_type));
      model.add_to_association(model_id, ATTRIBUTES, id);
    }

    return id;
  }

  function validate(address sender, uint id, uint[101][] attributes) returns(bool) {
    // Require all keys to be present, and all non-string types
    // to fit into one data slot.
    for (uint i = 0; i < keys.length; i++) {
      if (attributes[i][0] == 0) {
        ValidationError(keys[i][0], "must be present");
        return false;
      }
      if (keys[i][1] != STRING && attributes[i][0] != 1) {
        ValidationError(keys[i][0], "is invalid");
        return false;
      }
    }

    // Require MODEL_TYPE to be "dapp" or "developer"
    if (attributes[3][1] != DAPP && attributes[3][1] != DEVELOPER) {
      ValidationError(MODEL_TYPE, "has unknown value; must be 'dapp' or 'developer'");
      return false;
    }

    if (id != 0) {
      uint current_model_id = db.get_entry(id, MODEL_ID, 0);
      uint current_model_type = db.get_entry(id, MODEL_TYPE, 0);

      for (uint k = 0; k < keys.length; k++) {
        if (keys[k][0] == MODEL_ID && attributes[k][1] != current_model_id) {
          ValidationError(MODEL_ID, "cannot be changed after create()");
          return false;
        }
        if (keys[k][0] == MODEL_TYPE && attributes[k][1] != current_model_type) {
          ValidationError(MODEL_TYPE, "cannot be changed after create()");
          return false;
        }
      }
    }

    return true;
  }
}
