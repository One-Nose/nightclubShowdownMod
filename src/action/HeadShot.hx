package action;

class HeadShot extends Action {
    public var entity: en.Mob;

    public function new(entity: en.Mob) {
        super();

        this.entity = entity;
    }
}
