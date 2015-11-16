import "EternalDB";

contract AbstractModel {
  function set_db(EternalDB _db);
  function replace(address replacement);
}

contract ModelCoordinator {
  mapping(uint => address) public models;
  address public admin;

  function ModelCoordinator() {
    admin = msg.sender;
  }

  function register(uint name, AbstractModel model, EternalDB db) {
    if (msg.sender == admin) {
      if (models[name] != 0) {
        AbstractModel old_model = AbstractModel(models[name]);
        old_model.replace(model);
      }

      models[name] = address(model);

      if (address(db) == 0) {
        db = new EternalDB();
        db.transfer_ownership(address(model));
      }

      model.set_db(db);
    }
  }
}
