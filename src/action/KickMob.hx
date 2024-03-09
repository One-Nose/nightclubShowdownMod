package action;

class KickMob extends Action {
    public var mob: entity.Mob;
    public var side: Int;

    public function new(hero: entity.Hero, mob: entity.Mob, side: Int) {
        super(hero, "Kick enemy", 0xA6EE11, mob);

        this.mob = mob;
        this.side = side;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<Move> {
        var bestAction: Null<KickMob> = null;

        for (mob in entity.Mob.ALL) {
            var action = new KickMob(hero, mob, if (x < mob.centerX) -1 else 1);

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
            this.hero.spr.anim.isPlaying("heroKick")
        )
            return false;

        if (this.hero.distPxFree(
            this.mob.footX + this.side * 10, this.mob.footY
        ) >= 20)
            return null;

        return true;
    }

    function _execute() {
        Assets.SFX.hit1(1);
        this.mob.hit(1, this.hero);

        this.hero.lookAt(this.mob);
        this.hero.spr.anim.play("heroKick");
        if (this.mob.canBeGrabbed()) {
            this.mob.xr += 0.5 * this.hero.dirTo(this.mob);
            this.mob.violentBump(this.hero.dir * 0.5, -0.1, 1.5);
        } else
            this.hero.cd.setS("ctrlLock", 0.5);
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(
            this.mob.footX + this.side * Const.GRID / 1.5,
            this.mob.footY + Const.GRID / 2
        );
        this.hero.icon.set("iconKickGrab");

        super.updateDisplay();
    }

    public function equals(action: Action): Bool {
        var other: KickMob;
        try {
            other = cast(action, KickMob);
        } catch (e) {
            return false;
        }
        return this.mob == other.mob && this.side == other.side;
    }
}
