package action;

class HeadShot extends Action {
    public var mob: en.Mob;

    public function new(mob: en.Mob) {
        super("Head shot", 0xFF9300, mob);

        this.mob = mob;
    }

    public function execute(hero: en.Hero) {
        hero.getSkill("headShot")
            .prepareOn(this.mob, if (this.mob.isGrabbed()) 0.5 else 1);
    }

    public override function updateDisplay(hero: en.Hero) {
        hero.icon.setPos(this.mob.head.centerX, this.mob.head.centerY);
        hero.icon.set("iconShoot");

        super.updateDisplay(hero);
    }
}
