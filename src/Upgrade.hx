class Upgrade {
    public var name(default, null): String;
    public var onUnlock(default, null): () -> Void;
    public var isUnlockable(default, null): () -> Bool;

    var children: Array<Upgrade>;

    public function new(
        name: String, onUnlock: () -> Void, maxLevel = 1,
        ?children: Array<Upgrade>, ?isUnlockable: () -> Bool
    ) {
        this.name = name;
        this.onUnlock = onUnlock;
        this.children = children ?? [];
        if (maxLevel > 1)
            this.children.push(
                new Upgrade(name, onUnlock, maxLevel - 1, children)
            );
        this.isUnlockable = isUnlockable ?? () -> true;
    }

    public function claim() {
        this.onUnlock();

        Game.ME.unlockableUpgrades.remove(this);
        Game.ME.upgrades.push(this);
        for (upgrade in this.children)
            Game.ME.unlockableUpgrades.push(upgrade);
    }
}
