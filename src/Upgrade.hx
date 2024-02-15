class Upgrade {
    public var name(default, null): String;
    public var onUnlock(default, null): () -> Void;
    public var isUnlockable(default, null): () -> Bool;

    var children: Array<Upgrade>;

    public function new(name: String, config: {
        onUnlock: () -> Void,
        ?children: Array<Upgrade>,
        ?maxLevel: Int,
        ?isUnlockable: () -> Bool
    }) {
        this.name = name;
        this.onUnlock = config.onUnlock;
        this.children = config.children ?? [];
        if ((config.maxLevel ?? 1) > 1) {
            var childConfig = Reflect.copy(config);
            childConfig.maxLevel--;
            this.children.push(new Upgrade(name, childConfig));
        }
        this.isUnlockable = config.isUnlockable ?? () -> true;
    }

    public function claim() {
        this.onUnlock();

        Game.ME.unlockableUpgrades.remove(this);
        Game.ME.upgrades.push(this);
        for (upgrade in this.children)
            Game.ME.unlockableUpgrades.push(upgrade);
    }
}
