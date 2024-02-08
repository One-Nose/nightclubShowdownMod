package action;

class BlindShot extends Action {
    var mob: en.Mob;

    public function new(hero: en.Hero, mob: en.Mob) {
        super(hero, "Quick shoot", 0xFFFF00, mob);

        this.mob = mob;
    }

    public function execute() {
        this.hero.getSkill("blindShot")
            .prepareOn(this.mob, if (this.mob.isGrabbed()) 0.5 else 1);
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(
            this.mob.torso.centerX, this.mob.torso.centerY + 3
        );
        this.hero.icon.set(
            if (this.mob.isCoveredFrom(
                this.hero
            )) "iconShootCover" else "iconShoot"
        );

        if (this.mob.isCoveredFrom(this.hero)) {
            this.helpText += " (cover)";
            this.color = 0xFF0000;
        }

        super.updateDisplay();
    }
}
