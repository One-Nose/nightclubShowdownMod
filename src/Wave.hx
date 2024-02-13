class Wave {
    /** Sorted by the delay in seconds before appearing **/
    var entities: EntitiesMap;

    var color: dn.Col;

    public var mobCount(default, null): Int = 0;

    public function new(
        color: dn.Col, ...registries: {entity: Entity, ?delay: Float}) {
        this.color = color;

        this.entities = new EntitiesMap();

        for (registry in registries)
            this.registerEntity(registry.entity, registry.delay);
    }

    public function registerEntity(entity: Entity, delaySeconds: Float = 0) {
        this.entities[delaySeconds].push(entity);
        if (entity is entity.Mob)
            this.mobCount++;
    }

    public function start() {
        Game.ME.level.hue(Color.intToHsl(this.color).h * 6.28, 2.5);

        for (delay => delayEntities in this.entities)
            Game.ME.level.delayer.addS(() -> {
                for (entity in delayEntities ?? []) {
                    entity.init();
                    try {
                        cast(entity, entity.Mob).enterArena();
                    } catch (e) {}
                }
            }, delay);
    }
}

@:forward
abstract EntitiesMap(Map<String, Array<Entity>>) {
    public function new() {
        this = new Map();
    }

    public inline function set(key: Float, value: Array<Entity>)
        this.set(Std.string(key), value);

    @:arrayAccess public inline function get(key: Float) {
        if (!exists(key))
            set(key, []);
        return this.get(Std.string(key));
    }

    public inline function exists(key: Float)
        return this.exists(Std.string(key));

    public inline function remove(key: Float)
        return this.remove(Std.string(key));

    public inline function keys(): Iterator<Float> {
        var keys = this.keys();
        return {
            hasNext: keys.hasNext,
            next: () -> Std.parseFloat(keys.next())
        }
    }

    public inline function keyValueIterator(): KeyValueIterator<Float,
        Array<Entity>> {
        var iterator = this.keyValueIterator();
        return {
            hasNext: iterator.hasNext,
            next: () -> {
                var next = iterator.next();
                return {key: Std.parseFloat(next.key), value: next.value};
            }
        }
    }

    @:arrayAccess @:noCompletion public inline function arrayWrite(
        k: Float, v: Array<Entity>
    ): Array<Entity> {
        set(k, v);
        return v;
    }
}
