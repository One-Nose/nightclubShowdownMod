package action;

class Dash extends Action {
    public var x: Float;
    public var y: Float;

    public function new(hero: entity.Hero, x: Float, y: Float) {
        super(hero, "Dash", 0x44A9F7);

        this.x = x;
        this.y = y;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<Dash> {
        if (
            M.fabs(y - hero.footY - Const.GRID / 2) <= Const.GRID / 2 &&
            hero.grabbedMob == null
        ) {
            var tx = hero.footX + M.sign(x - hero.footX) * 5 * Const.GRID;
            tx = M.fclamp(tx, 5, hero.level.wid * Const.GRID - 5);
            if (
                hero.game.waveId <= 1 &&
                hero.level.waveMobCount > 0 &&
                tx >= (hero.level.wid - 3) * Const.GRID
            )
                tx = (hero.game.level.wid - 3) * Const.GRID;

            if (
                M.fabs(tx - x) <= Const.GRID * 3 &&
                M.fabs(hero.footX - tx) >= Const.GRID * 2
            )
                return new Dash(hero, tx, hero.footY);
        }
        return null;
    }

    public override function execute() {
        super.execute();

        this.hero.spr.anim.stopWithStateAnims();
        this.hero.speed *= 2;
        this.hero.moveTarget = new FPoint(this.x, this.y);
        this.hero.cd.setS("rolling", 0.3);
        this.hero.cd.setS("rollBraking", this.hero.cd.getS("rolling") + 0.3);
        this.hero.afterMoveAction = new action.None(this.hero);
        this.hero.leaveCover();
        this.hero.stopGrab();
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(this.x, this.y);
        this.hero.icon.set("iconKickGrab");

        super.updateDisplay();
    }
}
