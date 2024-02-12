import haxe.Json;

class Wave {
    /** Sorted by the delay in seconds before appearing **/
    var entities: EntitiesMap;

    public function new() {
        this.entities = new EntitiesMap();
    }

    public function registerEntity(entity: Entity, delaySeconds: Float = 0) {
        this.entities[delaySeconds].push(entity);
    }

    public function start() {
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
        this.set(Json.stringify(key), value);

    @:arrayAccess public inline function get(key: Float) {
        if (!exists(key))
            set(key, []);
        return this[Json.stringify(key)];
    }

    public inline function exists(key: Float)
        return this.exists(Json.stringify(key));

    public inline function remove(key: Float)
        return this.remove(Json.stringify(key));

    public inline function keys(): Iterator<Float> {
        var keys = this.keys();
        return {
            hasNext: keys.hasNext,
            next: () -> Json.parse(keys.next())
        }
    }

    public inline function keyValueIterator(): KeyValueIterator<Float,
        Array<Entity>> {
        var iterator = this.keyValueIterator();
        return {
            hasNext: iterator.hasNext,
            next: () -> {
                var next = iterator.next();
                return {key: Json.parse(next.key), value: next.value};
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
