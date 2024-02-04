package action;

class GrabMob extends Action {
    public var entity: en.Mob;
    public var side: Int;

    public function new(entity: en.Mob, side: Int) {
        super();

        this.entity = entity;
        this.side = side;
    }

    public function execute(hero: en.Hero) {
        if (hero.distPxFree(
            this.entity.footX + this.side * 10, this.entity.footY
        ) >= 20) {
            hero.stopGrab();
            hero.leaveCover();
            hero.moveTarget = new FPoint(
                this.entity.footX + this.side * 10, this.entity.footY
            );
            hero.afterMoveAction = new action.GrabMob(this.entity, this.side);
        } else {
            Assets.SFX.hit0(1);
            hero.dir = -this.side;
            hero.cx = this.entity.cx;
            hero.xr = this.entity.xr + this.side * 0.9;
            hero.startGrab(this.entity);
        }
    }
}
