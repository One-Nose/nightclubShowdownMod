package action;

class ChooseUpgrade extends Action {
    var upgradeEntity: entity.UpgradeEntity;

    function new(hero: entity.Hero, upgradeEntity: entity.UpgradeEntity) {
        super(hero, "Choose Upgrade", 0x44F1F7, upgradeEntity);

        this.upgradeEntity = upgradeEntity;
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<Move> {
        for (upgradeEntity in entity.UpgradeEntity.ALL)
            if (
                M.fabs(x - upgradeEntity.centerX) <= Const.GRID / 2 &&
                M.fabs(y - upgradeEntity.centerY) <= Const.GRID / 2
            ) {
                var action = new ChooseUpgrade(hero, upgradeEntity);
                if (action.canBePerformed() != false)
                    return new Move(
                        hero, upgradeEntity.footX, hero.footY, action
                    );
            }

        return null;
    }

    override function canBePerformed(): Null<Bool> {
        if (this.hero.distPx(this.upgradeEntity) < Const.GRID)
            return true;
        return null;
    }

    function _execute() {
        this.hero.dir = M.sign(this.upgradeEntity.footX - this.hero.footX);
        this.upgradeEntity.claim();
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(
            this.upgradeEntity.centerX,
            this.upgradeEntity.centerY - Const.GRID / 1.3
        );
        this.hero.icon.set("iconMove");

        this.upgradeEntity.hover();

        super.updateDisplay();
    }
}
