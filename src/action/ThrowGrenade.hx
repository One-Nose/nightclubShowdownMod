package action;

class ThrowGrenade extends Action {
    var x: Float;

    public function new(hero: entity.Hero, x: Float) {
        super(hero, 0xEEBE11, hero);

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
        this.hero.hasThrownGrenade = true;
    }

    override function updateDisplay(icon: HSprite, ?moveIcon: HSprite) {
        icon.setPos(this.x, this.hero.footY - 4 * Const.GRID);
        icon.set("iconGrenade");

        if (moveIcon != null) {
            moveIcon.visible = true;
            moveIcon.colorize(this.color);
        }

        super.updateDisplay(icon);
    }

    public function equals(action: Action): Bool {
        var other: ThrowGrenade;
        try {
            other = cast(action, ThrowGrenade);
        } catch (e) {
            return false;
        }
        return M.signEq(this.hero.footX - this.x, this.hero.footX - other.x);
    }
}
