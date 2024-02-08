package action;

class GrabMob extends Action {
    public var mob: en.Mob;
    public var side: Int;

    public function new(hero: en.Hero, mob: en.Mob, side: Int) {
        super(hero, "Grab enemy", 0xA6EE11, mob);

        this.mob = mob;
        this.side = side;
    }

    public function execute() {
        if (hero.distPxFree(
            this.mob.footX + this.side * 10, this.mob.footY
        ) >= 20) {
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
            this.mob.footX + this.side * 14, this.mob.footY - 6
        );
        this.hero.icon.set(
            "iconCover" + if (this.side == -1) "Left" else "Right"
        );

        super.updateDisplay();
    }
}
