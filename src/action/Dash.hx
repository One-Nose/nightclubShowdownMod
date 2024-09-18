package action;

class Dash extends Action {
    public var x: Float;
    public var y: Float;
    public var then: Action;

    var rollSeconds: Float;

    public function new(
        hero: entity.Hero, x: Float, rollSeconds = 0.3, ?then: Action
    ) {
        super(hero, 0x00F7FF);

        this.x = x;
        this.y = hero.footY;
        this.rollSeconds = rollSeconds;
        this.then = then ?? new None(hero);
        this.then.color = this.color;
    }

    public static function getX(hero: entity.Hero, side: Int): Null<Float> {
        var x = hero.footX + side * 5 * Const.GRID;
        x = M.fclamp(x, 5, hero.level.wid * Const.GRID - 5);

        if (
            hero.game.level.waveId <= 1 &&
            !hero.level.readyForStage2() &&
            x >= (hero.level.wid - 3) * Const.GRID
        )
            x = (hero.game.level.wid - 3) * Const.GRID;

        if (M.fabs(hero.footX - x) >= Const.GRID * 2)
            return x;

        return null;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<Dash> {
        if (M.fabs(y - hero.footY - Const.GRID / 1.5) <= Const.GRID / 1.5) {
            var tx = getX(hero, M.sign(x - hero.footX));

            if (tx == null)
                return null;

            var action = new Dash(hero, tx);

            if (
                action.canBePerformed() &&
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

            this.hero.hasDashed = true;

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

    public override function updateDisplay(icon: HSprite, ?moveIcon: HSprite) {
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
