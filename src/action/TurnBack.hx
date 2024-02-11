package action;

class TurnBack extends Action {
    public static function getInstance(
        hero: en.Hero, x: Float, y: Float
    ): Null<TurnBack> {
        if (
            hero.grabbedMob != null &&
            M.fabs(x - hero.centerX) >= Const.GRID &&
            (
                x > hero.centerX &&
                hero.dir == -1 ||
                x < hero.centerX &&
                hero.dir == 1
            )
        )
            return new TurnBack(hero);

        return null;
    }

    public override function execute() {
        super.execute();
        this.hero.dir *= -1;
    }
}
