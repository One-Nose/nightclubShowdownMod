package action;

class HeadShot extends Action {
    public var mob: entity.Mob;

    public function new(hero: entity.Hero, mob: entity.Mob) {
        super(hero, 0xFF4400, mob);

        this.mob = mob;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<HeadShot> {
        var bestAction: Null<HeadShot> = null;

        for (mob in entity.Mob.ALL) {
            var action = new HeadShot(hero, mob);

            if (
                action.canBePerformed() &&
                mob.head.contains(x, y) &&
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
            .getSkill("headShot")
            .prepareOn(this.mob, if (this.mob.isGrabbed()) 0.5 else 1);
    }

    public override function updateDisplay(icon: HSprite, ?moveIcon: HSprite) {
        icon.setPos(this.mob.head.centerX, this.mob.head.centerY);
        icon.set("iconShoot");

        super.updateDisplay(icon);
    }

    public function equals(action: Action): Bool {
        var other: HeadShot;
        try {
            other = cast(action, HeadShot);
        } catch (e) {
            return false;
        }
        return this.mob == other.mob;
    }
}
