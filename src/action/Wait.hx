package action;

class Wait extends Action {
    public var seconds: Float;

    public function new(seconds: Float) {
        super("Wait");

        this.seconds = seconds;
    }

    public function execute(hero: en.Hero) {
        hero.spr.anim.stopWithStateAnims();
        hero.lockControlsS(this.seconds);
    }

    public override function updateDisplay(hero: en.Hero) {
        hero.icon.setPos(hero.centerX, hero.footY);
        hero.icon.set("iconWait");

        super.updateDisplay(hero);
    }
}
