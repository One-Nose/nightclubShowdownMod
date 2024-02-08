package action;

class Wait extends Action {
    public var seconds: Float;

    public function new(hero: en.Hero, seconds: Float) {
        super(hero, "Wait");

        this.seconds = seconds;
    }

    public function execute() {
        this.hero.spr.anim.stopWithStateAnims();
        this.hero.lockControlsS(this.seconds);
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(this.hero.centerX, this.hero.footY);
        this.hero.icon.set("iconWait");

        super.updateDisplay();
    }
}
