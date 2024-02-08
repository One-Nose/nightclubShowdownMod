package action;

class TakeCover extends Action {
    public var cover: en.Cover;
    public var side: Int;

    public function new(hero: en.Hero, cover: en.Cover, side: Int) {
        super(hero, "Cover", 0xA6EE11, cover);

        this.cover = cover;
        this.side = side;
    }

    public function execute() {
        this.hero.spr.anim.stopWithStateAnims();

        if (this.cover.canHostSomeone(this.side)) {
            this.hero.stopGrab();

            if (this.hero.distPxFree(
                this.cover.centerX + this.side * 10, this.cover.centerY
            ) >= 20) {
                this.hero.moveTarget = new FPoint(
                    this.cover.centerX + this.side * 10, this.hero.footY
                );
                this.hero.afterMoveAction = this;
                this.hero.leaveCover();
            } else {
                this.hero.startCover(this.cover, this.side);
            }
        }
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(
            this.cover.footX + this.side * 14, this.cover.footY - 6
        );
        this.hero.icon.set(
            "iconCover" + if (this.side == -1) "Left" else "Right"
        );

        super.updateDisplay();
    }
}
