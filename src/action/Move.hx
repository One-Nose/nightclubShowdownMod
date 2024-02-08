package action;

class Move extends Action {
    public var x: Float;
    public var y: Float;

    public function new(hero: en.Hero, x: Float, y: Float) {
        super(hero);

        this.x = x;
        this.y = y;
    }

    public function execute() {
        this.hero.spr.anim.stopWithStateAnims();
        this.hero.moveTarget = new FPoint(this.x, this.y);
        // this.hero.cd.setS("rolling",0.5);
        this.hero.cd.setS("rollBraking", this.hero.cd.getS("rolling") + 0.1);
        this.hero.afterMoveAction = new action.None(this.hero);
        this.hero.leaveCover();
        this.hero.stopGrab();
    }
}
