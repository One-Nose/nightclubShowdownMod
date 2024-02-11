package action;

class HeadShot extends Action {
    public var mob: en.Mob;

    public function new(hero: en.Hero, mob: en.Mob) {
        super(hero, "Head shot", 0xFF9300, mob);

        this.mob = mob;
    }

    public static function getInstance(
        hero: en.Hero, x: Float, y: Float
    ): Null<HeadShot> {
        var best: Null<en.Mob> = null;
        for (mob in en.Mob.ALL) {
            if (
                mob.canBeShot() &&
                mob.head.contains(x, y) &&
                (best == null || mob.distPxFree(x, y) <= best.distPxFree(x, y))
            )
                best = mob;
        }
        if (best != null)
            return new HeadShot(hero, best);

        return null;
    }

    public override function execute() {
        super.execute();

        this.hero.getSkill("headShot")
            .prepareOn(this.mob, if (this.mob.isGrabbed()) 0.5 else 1);
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(this.mob.head.centerX, this.mob.head.centerY);
        this.hero.icon.set("iconShoot");

        super.updateDisplay();
    }
}
