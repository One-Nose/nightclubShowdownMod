package action;

class GrabMob extends Action {
    public var mob: entity.Mob;
    public var side: Int;

    public function new(hero: entity.Hero, mob: entity.Mob, side: Int) {
        super(hero, 0xA6EE11, mob);

        this.mob = mob;
        this.side = side;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<Action> {
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

        var actionX = bestAction.mob.footX + bestAction.side * 10;

        if (
            hero.canKickDash &&
            bestAction.side == M.sign(hero.footX - x) &&
            M.inRange(
                M.fabs(hero.footX - actionX), Const.GRID * 2, Const.GRID * 5
            )
        )
            return new Dash(hero, actionX, bestAction.mob.footY, bestAction);

        return new Move(hero, actionX, bestAction.mob.footY, bestAction);
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

        if (this.hero.startGrab(this.mob))
            this.hero.hasKicked = true;
    }

    public override function updateDisplay(icon: HSprite) {
        icon.setPos(
            this.mob.footX + this.side * Const.GRID / 1.5,
            this.mob.footY + Const.GRID / 2
        );
        icon.set("iconCover" + if (this.side == -1) "Left" else "Right");

        super.updateDisplay(icon);
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
