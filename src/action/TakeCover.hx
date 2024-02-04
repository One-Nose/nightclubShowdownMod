package action;

class TakeCover extends Action {
    public var cover: en.Cover;
    public var side: Int;

    public function new(cover: en.Cover, side: Int) {
        super("Cover", 0xA6EE11, cover);

        this.cover = cover;
        this.side = side;
    }

    public function execute(hero: en.Hero) {
        hero.spr.anim.stopWithStateAnims();

        if (this.cover.canHostSomeone(this.side)) {
            hero.stopGrab();

            if (hero.distPxFree(
                this.cover.centerX + this.side * 10, this.cover.centerY
            ) >= 20) {
                hero.moveTarget = new FPoint(
                    this.cover.centerX + this.side * 10, hero.footY
                );
                hero.afterMoveAction = this;
                hero.leaveCover();
            } else {
                hero.startCover(this.cover, this.side);
            }
        }
    }

    public override function updateDisplay(hero: en.Hero) {
        hero.icon.setPos(
            this.cover.footX + this.side * 14, this.cover.footY - 6
        );
        hero.icon.set("iconCover" + if (this.side == -1) "Left" else "Right");

        super.updateDisplay(hero);
    }
}
