package action;

class HeadShot extends Action {
    public var mob: en.Mob;

    public function new(hero: en.Hero, mob: en.Mob) {
        super(hero, "Head shot", 0xFF9300, mob);

        this.mob = mob;
    }

    public function execute() {
        this.hero.getSkill("headShot")
            .prepareOn(this.mob, if (this.mob.isGrabbed()) 0.5 else 1);
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(this.mob.head.centerX, this.mob.head.centerY);
        this.hero.icon.set("iconShoot");

        super.updateDisplay();
    }
}
