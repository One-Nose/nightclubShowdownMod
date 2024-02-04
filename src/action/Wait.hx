package action;

class Wait extends Action {
    public var seconds: Float;

    public function new(seconds: Float) {
        super();

        this.seconds = seconds;
    }

    public function execute(hero: en.Hero) {
        hero.spr.anim.stopWithStateAnims();
        hero.lockControlsS(this.seconds);
    }
}
