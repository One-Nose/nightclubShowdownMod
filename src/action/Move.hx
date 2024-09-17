package action;

class Move extends Action {
    public var x: Float;
    public var y: Float;
    public var then: Action;

    public function new(hero: entity.Hero, x: Float, y: Float, then: Action) {
        super(hero);

        this.x = x;
        this.y = y;
        this.then = then;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<Move> {
        if (M.fabs(y - hero.footY) <= 1.5 * Const.GRID) {
            var tx = x;
            tx = M.fclamp(tx, 5, hero.level.wid * Const.GRID - 5);
            if (
                hero.game.level.waveId <= 1 &&
                !hero.level.wave.isOver() &&
                tx >= (hero.level.wid - 3) * Const.GRID
            )
                tx = (hero.game.level.wid - 3) * Const.GRID;

            var action = new Move(hero, tx, hero.footY, new None(hero));
            if (action.canBePerformed())
                return action;
        }
        return null;
    }

    override function canBePerformed(): Null<Bool> {
        return hero.grabbedMob == null;
    }

    function _execute() {
        if (this.then.canBePerformed())
            then.execute();
        else {
            this.hero.spr.anim.stopWithStateAnims();
            this.hero.leaveCover();
            this.hero.stopGrab();

            this.hero.moveTarget = new FPoint(this.x, this.y);
            this.hero.cd.setS(
                "rollBraking", this.hero.cd.getS("rolling") + 0.1
            );
            this.hero.afterMoveAction = then ?? new None(this.hero);
        }
    }

    public override function updateDisplay(icon: HSprite, ?moveIcon: HSprite) {
        this.then.updateDisplay(icon);

        if (this.hero.level.waveId < 2 && !icon.visible && moveIcon != null)
            moveIcon.visible = true;
    }

    public function equals(action: Action): Bool {
        var other: Move;
        try {
            other = cast(action, Move);
        } catch (e) {
            return false;
        }
        return
            M.signEq(this.hero.footX - this.x, this.hero.footX - other.x) &&
            this.then.equals(other.then);
    }
}
