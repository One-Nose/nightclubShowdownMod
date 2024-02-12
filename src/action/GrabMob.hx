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
    ): Null<GrabMob> {
        var action: Null<GrabMob> = null;

        if (hero.grabbedMob == null) {
            var best: entity.Mob = null;
            for (mob in entity.Mob.ALL)
                if (
                    mob.canBeShot() &&
                    mob.canBeGrabbed() &&
                    hero.grabbedMob != mob &&
                    M.fabs(x - mob.centerX) <= Const.GRID &&
                    M.fabs(y - mob.centerY - Const.GRID) <= Const.GRID / 2 &&
                    (
                        best == null ||
                        mob.distPxFree(x, y) <= best.distPxFree(x, y)
                    )
                )
                    best = mob;
            if (best != null)
                action = new GrabMob(
                    hero, best, if (x < best.centerX) -1 else 1
                );
        }

        return action;
    }

    public override function execute() {
        super.execute();

        if (hero.distPxFree(
            this.mob.footX + this.side * 10, this.mob.footY
        ) >= 20) {
            this.hero.spr.anim.stopWithStateAnims();
            this.hero.stopGrab();
            this.hero.leaveCover();
            this.hero.moveTarget = new FPoint(
                this.mob.footX + this.side * 10, this.mob.footY
            );
            this.hero.afterMoveAction = new action.GrabMob(
                this.hero, this.mob, this.side
            );
        } else {
            Assets.SFX.hit0(1);
            this.hero.dir = -this.side;
            this.hero.cx = this.mob.cx;
            this.hero.xr = this.mob.xr + this.side * 0.9;
            this.hero.startGrab(this.mob);
        }
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
}
