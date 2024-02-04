package action;

class HeadShot extends Action {
    public var entity: en.Mob;

    public function new(entity: en.Mob) {
        super();

        this.entity = entity;
    }

    public function execute(hero: en.Hero) {
        hero.getSkill("headShot")
            .prepareOn(this.entity, if (this.entity.isGrabbed()) 0.5 else 1);
    }
}
