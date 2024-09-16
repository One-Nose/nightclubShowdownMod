using Upgrade;

class Upgrade {
    public var name(default, null): String;

    public var description(default, null): String;
    public var onUnlock(default, null): () -> Void;
    public var isUnlockable(default, null): () -> Bool;
    public var iconName(default, null): String;

    var array: Array<Upgrade> = null;
    var children: Array<Upgrade>;

    static public function addUpgrade(
        array: Array<Upgrade>, upgrade: Upgrade
    ): Array<Upgrade> {
        array.push(upgrade);
        upgrade.array = array;
        return array;
    }

    static public function initUpgrades(array: Array<Upgrade>): Array<Upgrade> {
        for (upgrade in array)
            upgrade.array = array;
        return array;
    }

    /**
        - `description`: Short description string
        - `onUnlock`: Function to call when the upgrade is claimed
        - `children`: Upgrades to add to unlockables when the upgrade is claimed.
            Not inherited by next level upgrades.
        - `maxLevel`: Amount of times the upgrade can be unlocked.
        - `isUnlockable`: A condition that must be met to unlock the upgrade.
        - `infinite`: Adds the upgrade as its own child.
    **/
    public function new(name: String, config: {
        description: String,
        onUnlock: () -> Void,
        ?children: Array<Upgrade>,
        ?maxLevel: Int,
        ?isUnlockable: () -> Bool,
        ?infinite: Bool,
        icon: String
    }) {
        this.name = name;

        var lines = [];
        var remaining = config.description + " ";
        while (remaining != "") {
            var index = 0;
            var lastIndex = 0;
            while (index <= 21 && index != -1) {
                lastIndex = index;
                index = remaining.indexOf(" ", index + 1);
            }
            lines.push(remaining.substring(0, lastIndex));
            remaining = remaining.substring(lastIndex + 1);
        }
        this.description = lines.join("\n");

        this.onUnlock = config.onUnlock;
        this.children = config.children ?? [];
        if (config.infinite)
            this.children.push(this);

        if ((config.maxLevel ?? 1) > 1) {
            var childConfig = Reflect.copy(config);
            childConfig.maxLevel--;
            childConfig.children = [];
            this.children.push(new Upgrade(name, childConfig));
        }

        this.isUnlockable = config.isUnlockable ?? () -> true;

        this.iconName = config.icon;
    }

    public function claim() {
        this.onUnlock();

        this.array.remove(this);
        for (upgrade in this.children)
            this.array.addUpgrade(upgrade);
    }
}
