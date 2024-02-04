package action;

class TakeCover extends Action {
    public var entity: en.Cover;
    public var side: Int;

    public function new(entity: en.Cover, side: Int) {
        super();

        this.entity = entity;
        this.side = side;
    }

    public function execute(hero: en.Hero) {
        hero.spr.anim.stopWithStateAnims();

        if (this.entity.canHostSomeone(this.side)) {
            hero.stopGrab();

            if (hero.distPxFree(
                this.entity.centerX + this.side * 10, this.entity.centerY
            ) >= 20) {
                hero.moveTarget = new FPoint(
                    this.entity.centerX + this.side * 10, hero.footY
                );
                hero.afterMoveAction = this;
                hero.leaveCover();
            } else {
                hero.startCover(this.entity, this.side);
            }
        }
    }
}
