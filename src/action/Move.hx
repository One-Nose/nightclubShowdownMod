package action;

class Move extends Action {
    public var x: Float;
    public var y: Float;

    public function new(hero: en.Hero, x: Float, y: Float) {
        super(hero);

        this.x = x;
        this.y = y;
    }

    public static function getInstance(
        hero: en.Hero, x: Float, y: Float
    ): Null<Move> {
        if (
            M.fabs(y - hero.footY) <= 1.5 * Const.GRID &&
            hero.grabbedMob == null
        ) {
            var movementOK = true;
            for (entity in Entity.ALL)
                if (
                    entity.isBlockingHeroMoves() &&
                    M.fabs(x - entity.centerX) <= Const.GRID * 0.8
                ) {
                    movementOK = false;
                    break;
                }

            if (movementOK) {
                var tx = x;
                tx = M.fclamp(tx, 5, hero.level.wid * Const.GRID - 5);
                if (
                    hero.game.waveId <= 1 &&
                    hero.level.waveMobCount > 0 &&
                    tx >= (hero.level.wid - 3) * Const.GRID
                )
                    tx = (hero.game.level.wid - 3) * Const.GRID;
                return new Move(hero, tx, hero.footY);
            }
        }
        return null;
    }

    public override function execute() {
        super.execute();

        this.hero.spr.anim.stopWithStateAnims();
        this.hero.moveTarget = new FPoint(this.x, this.y);
        // this.hero.cd.setS("rolling",0.5);
        this.hero.cd.setS("rollBraking", this.hero.cd.getS("rolling") + 0.1);
        this.hero.afterMoveAction = new action.None(this.hero);
        this.hero.leaveCover();
        this.hero.stopGrab();
    }
}
