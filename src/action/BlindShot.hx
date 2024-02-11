package action;

class BlindShot extends Action {
    var mob: entity.Mob;

    public function new(hero: entity.Hero, mob: entity.Mob) {
        super(hero, "Quick shoot", 0xFFFF00, mob);

        this.mob = mob;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<BlindShot> {
        var best: Null<entity.Mob> = null;
        for (mob in entity.Mob.ALL) {
            if (
                mob.canBeShot() &&
                (
                    mob.head.contains(x, y) ||
                    mob.torso.contains(x, y) ||
                    mob.legs.contains(x, y)
                ) &&
                (best == null || mob.distPxFree(x, y) <= best.distPxFree(x, y))
            )
                best = mob;
        }
        if (best != null)
            return new BlindShot(hero, best);

        return null;
    }

    public override function execute() {
        super.execute();
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
