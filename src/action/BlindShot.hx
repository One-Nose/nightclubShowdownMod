package action;

class BlindShot extends Action {
    var mob: en.Mob;

    public function new(mob: en.Mob) {
        super("Quick shoot", 0xFFFF00, mob);

        this.mob = mob;
    }

    public function execute(hero: en.Hero) {
        hero.getSkill("blindShot")
            .prepareOn(this.mob, if (this.mob.isGrabbed()) 0.5 else 1);
    }

    public override function updateDisplay(hero: en.Hero) {
        hero.icon.setPos(this.mob.torso.centerX, this.mob.torso.centerY + 3);
        hero.icon.set(
            if (this.mob.isCoveredFrom(hero)) "iconShootCover" else "iconShoot"
        );

        if (this.mob.isCoveredFrom(hero)) {
            this.helpText += " (cover)";
            this.color = 0xFF0000;
        }

        super.updateDisplay(hero);
    }
}
