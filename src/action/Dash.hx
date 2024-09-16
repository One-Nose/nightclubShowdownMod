package action;

class Dash extends Action {
    public var x: Float;
    public var y: Float;
    public var then: Action;

    var rollSeconds: Float;

    public function new(
        hero: entity.Hero, x: Float, y: Float, rollSeconds = 0.3, ?then: Action
    ) {
        super(hero, 0x00F7FF);

        this.x = x;
        this.y = y;
        this.rollSeconds = rollSeconds;
        this.then = then ?? new None(hero);
        this.then.color = this.color;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<Dash> {
        if (M.fabs(y - hero.footY - Const.GRID / 1.5) <= Const.GRID / 1.5) {
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
                M.fabs(hero.footX - action.x) >= Const.GRID * 2 &&
                M.fabs(action.x - x) <= Const.GRID * 3
            )
                return action;
        }
        return null;
    }

    override function canBePerformed(): Null<Bool> {
        return this.hero.grabbedMob == null;
    }

    function _execute() {
        if (this.then.canBePerformed())
            this.then.execute();
        else {
            this.hero.spr.anim.stopWithStateAnims();
            this.hero.leaveCover();
            this.hero.stopGrab();

            Assets.SFX.land0(1);
            this.hero.speed *= 2;
            this.hero.moveTarget = new FPoint(this.x, this.y);
            this.hero.cd.setS("rolling", this.rollSeconds);
            this.hero.cd.setS(
                "rollBraking", this.hero.cd.getS("rolling") + 0.3
            );
            this.hero.afterMoveAction = this.then;
        }
    }

    public override function updateDisplay(icon: HSprite) {
        if (this.then is None) {
            icon.setPos(this.x, this.y);
            icon.set("iconDash");

            super.updateDisplay(icon);
        } else {
            this.then.updateDisplay(icon);
        }
    }

    public function equals(action: Action): Bool {
        var other: Dash;
        try {
            other = cast(action, Dash);
        } catch (e) {
            return false;
        }
        return
            M.cmpAbs(this.x, other.x, .1) &&
            M.cmpAbs(this.y, other.y, .1) &&
            this.then.equals(other.then);
    }
}
