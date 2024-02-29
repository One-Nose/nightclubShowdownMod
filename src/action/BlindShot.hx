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
        var bestAction: Null<BlindShot> = null;

        for (mob in entity.Mob.ALL) {
            var action = new BlindShot(hero, mob);

            if (
                action.canBePerformed() &&
                (
                    mob.head.contains(x, y) ||
                    mob.torso.contains(x, y) ||
                    mob.legs.contains(x, y)
                ) &&
                (
                    bestAction == null ||
                    mob.distPxFree(x, y) <= bestAction.mob.distPxFree(x, y)
                )
            )
                bestAction = action;
        }

        return bestAction;
    }

    override function canBePerformed(): Null<Bool> {
        return this.mob.canBeShot();
    }

    function _execute() {
        this.hero
            .getSkill("blindShot")
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

    public function equals(action: Action): Bool {
        var other: BlindShot;
        try {
            other = cast(action, BlindShot);
        } catch (e) {
            return false;
        }
        return this.mob == other.mob;
    }
}
