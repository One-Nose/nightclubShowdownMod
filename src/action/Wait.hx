package action;

class Wait extends Action {
    public var seconds: Float;

    public function new(hero: entity.Hero, seconds: Float) {
        super(hero, 0xFFFFFF);

        this.seconds = seconds;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<Wait> {
        var action = new Wait(hero, 0.6);

        if (
            action.canBePerformed() &&
            M.fabs(hero.centerX - x) <= Const.GRID * 0.3 &&
            M.fabs(hero.centerY - y + Const.GRID / 3) <= Const.GRID * 0.7
        )
            return action;

        return null;
    }

    override function canBePerformed(): Null<Bool> {
        return hero.game.isSlowMo();
    }

    function _execute() {
        this.hero.spr.anim.stopWithStateAnims();
        this.hero.lockControlsS(this.seconds);
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(this.hero.centerX, this.hero.footY);
        this.hero.icon.set("iconWait");

        super.updateDisplay();
    }

    public function equals(action: Action): Bool {
        var other: Wait;
        try {
            other = cast(action, Wait);
        } catch (e) {
            return false;
        }
        return this.seconds == other.seconds;
    }
}
