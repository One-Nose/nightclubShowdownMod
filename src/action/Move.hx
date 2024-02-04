package action;

class Move extends Action {
    public var x: Float;
    public var y: Float;

    public function new(x: Float, y: Float) {
        super();

        this.x = x;
        this.y = y;
    }

    public function execute(hero: en.Hero) {
        hero.spr.anim.stopWithStateAnims();
        hero.moveTarget = new FPoint(this.x, this.y);
        // hero.cd.setS("rolling",0.5);
        hero.cd.setS("rollBraking", hero.cd.getS("rolling") + 0.1);
        hero.afterMoveAction = new action.None();
        hero.leaveCover();
        hero.stopGrab();
    }
}
