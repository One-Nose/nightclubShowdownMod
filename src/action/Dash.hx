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
        if (M.fabs(y - hero.footY - Const.GRID / 2) <= Const.GRID / 2) {
            var tx = hero.footX + M.sign(x - hero.footX) * 5 * Const.GRID;
            tx = M.fclamp(tx, 5, hero.level.wid * Const.GRID - 5);
            if (
                hero.game.level.waveId <= 1 &&
                !hero.level.wave.isOver() &&
                tx >= (hero.level.wid - 3) * Const.GRID
            )
                tx = (hero.game.level.wid - 3) * Const.GRID;

            var action = new Dash(hero, tx, hero.footY);

            if (
                action.canBePerformed() &&
                M.fabs(action.x - x) <= Const.GRID * 3
            )
                return action;
        }
        return null;
    }

    override function canBePerformed(): Null<Bool> {
        return
            hero.grabbedMob == null &&
            M.fabs(this.hero.footX - this.x) >= Const.GRID * 2;
    }

    function _execute() {
        this.hero.spr.anim.stopWithStateAnims();
        this.hero.speed *= 2;
        this.hero.moveTarget = new FPoint(this.x, this.y);
        this.hero.cd.setS("rolling", 0.3);
        this.hero.cd.setS("rollBraking", this.hero.cd.getS("rolling") + 0.3);
        this.hero.afterMoveAction = new action.None(this.hero);
        this.hero.leaveCover();
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(this.x, this.y);
        this.hero.icon.set("iconKickGrab");

        super.updateDisplay();
    }
}
