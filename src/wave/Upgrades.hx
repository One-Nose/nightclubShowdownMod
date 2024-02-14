package wave;

class Upgrades extends Wave {
    public function new(...registries) {
        super(...registries);
        this.isRewarding = false;
    }

    public function isOver(): Bool {
        return entity.UpgradeEntity.ALL.length <= 0;
    }
}
