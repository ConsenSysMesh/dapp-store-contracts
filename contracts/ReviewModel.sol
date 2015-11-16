import "Model";
import_headers "DeveloperModel";
import_headers "VersionModel";

contract ReviewModel is Model {
  uint constant VERSION_ID = 0x76657273696f6e5f6964;
  uint constant RATING = 0x726174696e67;
  uint constant DATE = 0x64617465;
  uint constant SUBJECT = 0x7375626a656374;
  uint constant TEXT = 0x74657874;

  uint constant VERSION = 0x76657273696f6e;
  uint constant DEVELOPER = 0x646576656c6f706572;

  uint constant REVIEWS = 0x72657669657773; // "reviews"

  uint constant MODEL_ID = 0x6d6f64656c5f6964; // "model_id"
  uint constant MODEL_TYPE = 0x6d6f64656c5f74797065; // "model_type"

  function ReviewModel() {
    keys.length = 6;

    keys[0][0] = MODEL_ID;
    keys[1][0] = MODEL_TYPE;
    keys[2][0] = RATING;
    keys[3][0] = DATE;
    keys[4][0] = SUBJECT;
    keys[5][0] = TEXT;

    keys[0][1] = POLYMORPHIC_REFERENCE;
    keys[1][1] = POLYMORPHIC_TYPE;
    keys[2][1] = INTEGER;
    keys[3][1] = DATETIME;
    keys[4][1] = STRING;
    keys[5][1] = STRING;

    read_only.length = 1;
    read_only[0][0] = ADDRESS;
    read_only[0][1] = ADDRESS;
  }

  function create(uint[101][] attributes) returns(uint) {
    uint id = super.create(attributes);

    if (id != 0) {
      // This is a little gross, but it seemed easier than consolidating
      // the rating code into a separate contract. TODO: It should be consolidated.
      if (attributes[1][1] == DEVELOPER) {
        DeveloperModel developer_model = DeveloperModel(coordinator.models(attributes[1][1]));
        uint developer_id = attributes[0][1];
        developer_model.add_to_association(developer_id, REVIEWS, id);
        developer_model.add_rating(developer_id, attributes[2][1]);
      }

      if (attributes[1][1] == VERSION) {
        VersionModel version_model = VersionModel(coordinator.models(attributes[1][1]));
        uint version_id = attributes[0][1];
        version_model.add_to_association(version_id, REVIEWS, id);
        version_model.add_rating(version_id, attributes[2][1]);
      }

      db.add(id, ADDRESS, uint(msg.sender));
    }

    return id;
  }

  function validate(address sender, uint id, uint[101][] attributes) returns(bool) {
    // Require model ID to be present, and fit into one data slot
    if (attributes[0][0] != 1) {
      ValidationError(MODEL_ID, "must be present");
      return false;
    }

    if (attributes[1][0] != 1) {
      ValidationError(MODEL_TYPE, "must be present");
      return false;
    }

    if (attributes[1][1] != DEVELOPER && attributes[1][1] != VERSION) {
      ValidationError(MODEL_TYPE, "invalid");
      return false;
    }

    // Require model id to be valid
    Model model = Model(coordinator.models(attributes[1][1]));
    EternalDB model_db = EternalDB(model.db());
    uint model_id = attributes[0][1];
    if (model_db.count() < model_id) {
      ValidationError(MODEL_ID, "invalid");
      return false;
    }

    // Require rating to be present, and fit into one data slot
    if (attributes[2][0] != 1) {
      ValidationError(RATING, "must be present");
      return false;
    }

    // Require rating to be between 1 and 5
    if (attributes[2][1] < 1 || attributes[2][1] > 5) {
      ValidationError(RATING, "must be between 1 and 5");
      return false;
    }

    return true;
  }
}
