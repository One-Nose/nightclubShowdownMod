package action;

class TakeCover extends Action {
    public var cover: entity.Cover;
    public var side: Int;

    public function new(hero: entity.Hero, cover: entity.Cover, side: Int) {
        super(hero, "Cover", 0xA6EE11, cover);

        this.cover = cover;
        this.side = side;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<Action> {
        var action: Null<TakeCover> = null;

        for (entity in entity.Cover.ALL) {
            var rightCover = new TakeCover(hero, entity, -1);
            if (
                rightCover.canBePerformed() != false &&
                entity.left.contains(x, y - Const.GRID * 1.5)
            )
                action = rightCover;

            var leftCover = new TakeCover(hero, entity, 1);
            if (
                leftCover.canBePerformed() != false &&
                entity.right.contains(x, y - Const.GRID * 1.5)
            )
                action = leftCover;
        }

        if (action == null)
            return null;

        var actionX = action.cover.centerX + action.side * 10;

        if (
            hero.canCoverDash &&
            M.inRange(
                M.fabs(hero.footX - actionX), Const.GRID * 2, Const.GRID * 5
            )
        )
            return new Dash(hero, actionX, hero.footY, Const.INFINITE, action);

        return new Move(hero, actionX, hero.footY, action);
    }

    override function canBePerformed(): Null<Bool> {
        if (this.cover.onGround && !this.cover.canHostSomeone(this.side))
            return false;

        if (this.hero.distPxFree(
            this.cover.centerX + this.side * 10, this.hero.footY
        ) >= 20)
            return null;

        return true;
    }

    function _execute() {
        this.hero.spr.anim.stopWithStateAnims();
        this.hero.stopGrab();

        this.hero.startCover(this.cover, this.side);
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(
            this.cover.footX + this.side * 14,
            this.cover.footY + Const.GRID / 2
        );
        this.hero.icon.set(
            "iconCover" + if (this.side == -1) "Left" else "Right"
        );

        super.updateDisplay();
    }

    public function equals(action: Action): Bool {
        var other: TakeCover;
        try {
            other = cast(action, TakeCover);
        } catch (e) {
            return false;
        }
        return this.cover == other.cover && this.side == other.side;
    }
}
