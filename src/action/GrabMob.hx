package action;

class GrabMob extends Action {
    public var mob: en.Mob;
    public var side: Int;

    public function new(mob: en.Mob, side: Int) {
        super("Grab enemy", 0xA6EE11, mob);

        this.mob = mob;
        this.side = side;
    }

    public function execute(hero: en.Hero) {
        if (hero.distPxFree(
            this.mob.footX + this.side * 10, this.mob.footY
        ) >= 20) {
            hero.stopGrab();
            hero.leaveCover();
            hero.moveTarget = new FPoint(
                this.mob.footX + this.side * 10, this.mob.footY
            );
            hero.afterMoveAction = new action.GrabMob(this.mob, this.side);
        } else {
            Assets.SFX.hit0(1);
            hero.dir = -this.side;
            hero.cx = this.mob.cx;
            hero.xr = this.mob.xr + this.side * 0.9;
            hero.startGrab(this.mob);
        }
    }

    public override function updateDisplay(hero: en.Hero) {
        hero.icon.setPos(this.mob.footX + this.side * 14, this.mob.footY - 6);
        hero.icon.set("iconCover" + if (this.side == -1) "Left" else "Right");

        super.updateDisplay(hero);
    }
}
