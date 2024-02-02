package action;

class GrabMob extends Action {
    public var entity: en.Mob;
    public var side: Int;

    public function new(entity: en.Mob, side: Int) {
        super();

        this.entity = entity;
        this.side = side;
    }
}
