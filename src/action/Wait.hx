package action;

class Wait extends Action {
    public var seconds: Float;

    public function new(hero: en.Hero, seconds: Float) {
        super(hero, "Wait");

        this.seconds = seconds;
    }

    public static function getInstance(
        hero: en.Hero, x: Float, y: Float
    ): Null<Wait> {
        if (
            hero.game.isSlowMo() &&
            hero.ammo >= hero.maxAmmo &&
            M.fabs(hero.centerX - x) <= Const.GRID * 0.3 &&
            M.fabs(hero.centerY - y + Const.GRID / 3) <= Const.GRID * 0.7
        )
            return new Wait(hero, 0.6);

        return null;
    }

    public override function execute() {
        super.execute();

        this.hero.spr.anim.stopWithStateAnims();
        this.hero.lockControlsS(this.seconds);
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(this.hero.centerX, this.hero.footY);
        this.hero.icon.set("iconWait");

        super.updateDisplay();
    }
}
