package action;

class GrabMob extends Action {
    public var mob: entity.Mob;
    public var side: Int;

    public function new(hero: entity.Hero, mob: entity.Mob, side: Int) {
        super(hero, "Grab enemy", 0xA6EE11, mob);

        this.mob = mob;
        this.side = side;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<Move> {
        var bestAction: Null<GrabMob> = null;

        for (mob in entity.Mob.ALL) {
            var action = new GrabMob(hero, mob, if (x < mob.centerX) -1 else 1);

            if (
                action.canBePerformed() != false &&
                M.fabs(x - mob.centerX) <= Const.GRID &&
                M.fabs(y - mob.centerY - Const.GRID) <= Const.GRID / 2 &&
                (
                    bestAction == null ||
                    mob.distPxFree(x, y) <= bestAction.mob.distPxFree(x, y)
                )
            )
                bestAction = action;
        }

        if (bestAction == null)
            return null;

        return new Move(
            hero,
            bestAction.mob.footX + bestAction.side * 10,
            bestAction.mob.footY,
            bestAction
        );
    }

    override function canBePerformed(): Null<Bool> {
        if (
            this.hero.grabbedMob != null ||
            !this.mob.canBeShot() ||
            !this.mob.canBeGrabbed()
        )
            return false;

        if (this.hero.distPxFree(
            this.mob.footX + this.side * 10, this.mob.footY
        ) >= 20)
            return null;

        return true;
    }

    function _execute() {
        this.hero.spr.anim.stopWithStateAnims();
        this.hero.leaveCover();

        Assets.SFX.hit0(1);
        this.hero.dir = -this.side;
        this.hero.cx = this.mob.cx;
        this.hero.xr = this.mob.xr + this.side * 0.9;
        this.hero.startGrab(this.mob);
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(
            this.mob.footX + this.side * Const.GRID / 1.5,
            this.mob.footY + Const.GRID / 2
        );
        this.hero.icon.set(
            "iconCover" + if (this.side == -1) "Left" else "Right"
        );

        super.updateDisplay();
    }

    public function equals(action: Action): Bool {
        var other: GrabMob;
        try {
            other = cast(action, GrabMob);
        } catch (e) {
            return false;
        }
        return this.mob == other.mob && this.side == other.side;
    }
}
