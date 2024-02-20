package action;

class ThrowGrenade extends Action {
    var x: Float;

    public function new(hero: entity.Hero, x: Float) {
        super(hero, "Throw grenade", 0xEEBE11, hero);

        this.x = x;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<ThrowGrenade> {
        var action = new ThrowGrenade(hero, x);
        if (action.canBePerformed())
            return action;
        return null;
    }

    override function canBePerformed(): Null<Bool> {
        return
            this.hero.grenades > 0 &&
            M.fabs(this.hero.footX - this.x) > 2 * Const.GRID;
    }

    function _execute() {
        this.hero.grenades--;
        this.hero.game.updateHud();
        this.hero.getSkill("throwGrenade").prepareAt(this.x);
    }

    override function updateDisplay() {
        this.hero.icon.setPos(this.x, this.hero.footY - Const.GRID / 4);
        this.hero.icon.set("iconMove");

        super.updateDisplay();
    }
}
