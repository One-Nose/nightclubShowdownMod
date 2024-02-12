package action;

class TurnBack extends Action {
    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<TurnBack> {
        var action = new TurnBack(hero);

        if (
            action.canBePerformed() &&
            M.fabs(x - hero.centerX) >= Const.GRID &&
            (
                x > hero.centerX &&
                hero.dir == -1 ||
                x < hero.centerX &&
                hero.dir == 1
            )
        )
            return action;

        return null;
    }

    override function canBePerformed(): Null<Bool> {
        return hero.grabbedMob != null;
    }

    function _execute() {
        this.hero.dir *= -1;
    }
}
