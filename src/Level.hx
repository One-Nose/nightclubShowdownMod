import entity.Cover;
import entity.mob.*;

typedef ShopEntry = {
    price: Int,
    createMob: (x: Int, y: Int, dir: Null<Int>) -> entity.Mob,
    ?accumulativePrice: Int,
}

class Level extends dn.Process {
    public var waveId: Int;

    public var wid: Int;
    public var hei: Int;

    public var debug: h2d.Graphics;

    var collMap: haxe.ds.Vector<Bool>;

    var crowd: h2d.Object;
    var bg: HSprite;
    var front: HSprite;
    var circle: HSprite;
    var people: Array<HSprite>;

    public var wave: Wave;

    var waves: Array<Wave>;
    var mobShop: Array<ShopEntry> = [
        {price: 1, createMob: BasicGun.new},
        {price: 3, createMob: Heavy.new, accumulativePrice: 3},
        {price: 5, createMob: Grenader.new},
    ];

    public function new() {
        super(Game.ME);

        wid = 20;
        hei = 7;
        collMap = new haxe.ds.Vector(wid * hei);

        createRootInLayers(Game.ME.scroller, Const.BACKGROUND_LAYER);

        var mask = new h2d.Graphics(root);
        mask.beginFill(0x0, 1);
        mask.drawRect(0, 0, wid * Const.GRID, hei * Const.GRID);

        this.waves = [
            new Wave(
                0xF60000,
                {entity: new BasicGun(14, 6, -1)},
                {entity: new BasicGun(19, 6, -1)},
            ),
            new Wave(
                0xF60000,
                {entity: new BasicGun(3, 6, 1)},
                {entity: new BasicGun(19, 6, -1)},

                {entity: new BasicGun(0, 6, 1), delay: 3.5},
                {entity: new BasicGun(9, 6, -1), delay: 3.5},
                {entity: new BasicGun(14, 6, -1), delay: 3.5},
                {entity: new BasicGun(19, 6, -1), delay: 3.5},
            ),
            new Wave(
                0xF60000,
                {entity: new Cover(14, 3)},
                {entity: new BasicGun(6, 4, -1)},
                {entity: new BasicGun(10, 4, -1)},
                {entity: new BasicGun(18, 4, -1)},

                {entity: new BasicGun(1, 4, 1), delay: 3.5},
                {entity: new BasicGun(15, 4, -1), delay: 3.5},
                {entity: new Heavy(19, 4, -1), delay: 3.5},
            ),
            new Wave(
                0x0D54F6,
                {entity: new Cover(7, 3)},
                {entity: new BasicGun(4, 4, 1)},
                {entity: new Grenader(12, 4, 1)},

                {entity: new BasicGun(1, 4, 1), delay: 3.5},
            ),
            new Wave(
                0xF60000,
                {entity: new Cover(15, 3)},
                {entity: new BasicGun(5, 4, 1)},
                {entity: new BasicGun(18, 4, -1)},
                {entity: new Grenader(1, 4, 1)},

                {entity: new BasicGun(1, 4, 1), delay: 3.5},
                {entity: new Heavy(19, 4, -1), delay: 3.5},

                {entity: new BasicGun(11, 4, -1), delay: 7},
            ),
            new Wave(
                0x0D54F6,
                {entity: new Cover(6, 3)},
                {entity: new BasicGun(5, 4, 1)},
                {entity: new Grenader(18, 4, -1)},

                {entity: new BasicGun(10, 4, -1), delay: 3.5},
                {entity: new Grenader(1, 4, 1), delay: 3.5},

                {entity: new BasicGun(13, 4, -1), delay: 7},
            ),
            new Wave(
                0xD600F6,
                {entity: new Cover(5, 3)},
                {entity: new BasicGun(1, 4, 1)},
                {entity: new BasicGun(16, 4, -1)},

                {entity: new BasicGun(7, 4, 1), delay: 3.5},
                {entity: new Grenader(3, 4, 1), delay: 3.5},

                {entity: new BasicGun(4, 4, 1), delay: 7},
                {entity: new BasicGun(10, 4, -1), delay: 7},
                {entity: new Grenader(18, 4, -1), delay: 7},
            ),
            new Wave(
                0xF60000,
                {entity: new Cover(1, 3)},
                {entity: new Cover(6, 3)},
                {entity: new Cover(9, 3)},
                {entity: new Cover(13, 3)},
                {entity: new Cover(17, 3)},
                {entity: new BasicGun(2, 4, 1)},
                {entity: new BasicGun(7, 4, 1)},
                {entity: new BasicGun(11, 4, 1)},

                {entity: new BasicGun(4, 4, -1), delay: 3.5},
                {entity: new BasicGun(18, 4, -1), delay: 3.5},
                {entity: new Grenader(9, 4, 1), delay: 3.5},

                {entity: new BasicGun(5, 4, -1), delay: 7},
                {entity: new Grenader(11, 4, -1), delay: 7},
                {entity: new Grenader(15, 4, -1), delay: 7},
                {entity: new Grenader(18, 4, -1), delay: 7},
            ),
        ];
    }

    public function prepareWave(waveId: Int) {
        this.waveId = waveId;
        this.render();
    }

    function render() {
        if (bg != null) {
            bg.remove();
            debug.remove();
            front.remove();
            circle.remove();
            for (e in people)
                e.remove();
            root.removeChildren();
        }
        people = [];
        collMap = new haxe.ds.Vector(wid * hei);
        var game = Game.ME;

        if (waveId == 2)
            Assets.playMusic(true);

        switch (waveId) {
            case 0, 1:
                bg = Assets.gameElements.h_get("bgOut", root);

                front = Assets.gameElements.h_get("bgOver");
                Game.ME.scroller.add(front, Const.TOP_LAYER);
                front.x = -32;

                circle = Assets.gameElements.h_get("redCircle", 0, 0.5, 0.5);
                Game.ME.scroller.add(circle, Const.BACKGROUND_LAYER);
                circle.x = wid - 36;
                circle.y = 34;
                circle.blendMode = Add;

            default:
                for (x in 0...wid)
                    for (y in hei - 2...hei)
                        setColl(x, y, true);

                bg = Assets.gameElements.h_get("bg", root);

                collMap = new haxe.ds.Vector(wid * hei);
                for (x in 0...wid)
                    for (y in hei - 2...hei)
                        setColl(x, y, true);

                crowd = new h2d.Object(root);
                people = [];

                function getDancer()
                    return switch (Std.random(3)) {
                        case 0: "dancingA";
                        case 1: "dancingB";
                        case 2: "dancingC";
                        default: "dancingA";
                    }
                var x = 10;
                while (x < wid * Const.GRID) {
                    var e = Assets.gameElements.h_get("dancingA", crowd);
                    e.anim.playAndLoop(getDancer()).setSpeed(rnd(0.8, 1));
                    e.setPos(x, hei * Const.GRID - 14 - rnd(25, 30));
                    e.setCenterRatio(0.5, 1);
                    e.setScale(rnd(0.6, 0.7));
                    e.colorize(0x830E4F);
                    // e.alpha = 0.4;
                    people.push(e);
                    x += irnd(6, 15);
                }
                var x = 0;
                while (x < wid * Const.GRID) {
                    var e = Assets.gameElements.h_get("dancingA", crowd);
                    e.anim.playAndLoop(getDancer()).setSpeed(rnd(0.85, 1.1));
                    e.setPos(x, hei * Const.GRID - 3 - rnd(25, 30));
                    e.setCenterRatio(0.5, 1);
                    e.colorize(0x680261);
                    people.push(e);
                    x += irnd(6, 15);
                }
                var x = 6;
                while (x < wid * Const.GRID) {
                    var e = Assets.gameElements.h_get("dancingA", crowd);
                    e.anim.playAndLoop(getDancer()).setSpeed(rnd(0.85, 1.1));
                    e.setPos(x, hei * Const.GRID - rnd(25, 30));
                    e.setCenterRatio(0.5, 1);
                    e.colorize(0x29004A);
                    people.push(e);
                    x += irnd(6, 15);
                }

                for (cx in 0...wid) {
                    var e = Assets.gameElements.h_getRandom("ground", root);
                    e.x = cx * Const.GRID;
                    e.y = (hei - 2) * Const.GRID;
                }

                front = Assets.gameElements.h_get("bgOver");
                Game.ME.scroller.add(front, Const.TOP_LAYER);
                front.x = -32;

                var bottomLight = Assets.gameElements.h_get(
                    "bottomLight", 0, 0, 1, root
                );
                // Game.ME.scroller.add(bottomLight, Const.DP_BG);
                bottomLight.y = 5 * Const.GRID;
                bottomLight.blendMode = Add;
                bottomLight.colorize(0xAF40BF);
                bottomLight.alpha = 0.6;
                bottomLight.scaleY = 0.5;

                circle = Assets.gameElements.h_get("redCircle", 0, 0.5, 0.5);
                Game.ME.scroller.add(circle, Const.BACKGROUND_LAYER);
                circle.x = wid * 0.5 * Const.GRID - 5;
                circle.y = 2 * Const.GRID;
                circle.blendMode = Add;
        }

        debug = new h2d.Graphics(root);
    }

    override function onDispose() {
        super.onDispose();
        front.remove();
    }

    var curHue = 0.;

    public function hue(ang: Float, sec: Float) {
        tw.createS(curHue, ang, sec).onUpdate = function() {
            bg.colorMatrix = new h3d.Matrix();
            bg.colorMatrix.identity();
            bg.colorMatrix.colorHue(curHue);
            for (e in people) {
                e.colorMatrix = new h3d.Matrix();
                e.colorMatrix.identity();
                e.colorMatrix.colorHue(curHue);
            }
        }
    }

    public function startWave() {
        var waveColors = [0xF60000, 0x0D54F6, 0xD600F6];

        var waveColorIndex: dn.Col;

        if (this.waveId <= 1)
            waveColorIndex = 0;
        else if (this.waveId <= 5)
            waveColorIndex = this.waveId % 2;
        else
            waveColorIndex = (this.waveId - 1) % 3;

        var wave = new Wave(waveColors[waveColorIndex]);

        var mod = this.waveId % 8;
        var points: Float = M.floor(this.waveId / 8) * 10;

        points += 2.16 * Math.pow(1.47, mod + Math.random() * 0.8 - 0.5);
        if ([1, 2, 4, 7].contains(mod))
            points += 5.9;
        points = M.fmax(points, 2.2);

        var shop = this.mobShop.filter(
            entry -> entry.price <= M.fmax(this.waveId, 1) * 2
        );
        var delay = 0.0;
        while (true) {
            var maxBatchSize = 0;
            for (batchSize in 1...5) {
                if (batchSize * Math.log(batchSize + 1) <= points)
                    maxBatchSize = batchSize;
                else
                    break;
            }
            if (maxBatchSize == 0)
                break;

            var batchSize: Int;
            if (delay >= 7 || (delay >= 3.5 && mod <= 1)) {
                batchSize = maxBatchSize;
                points = batchSize * Math.log(batchSize + 1);
            } else
                batchSize = M.randRange(M.imin(maxBatchSize, 2), maxBatchSize);

            var batchPoints = points / Math.log(batchSize + 1);
            var registeredMobs = 0;
            var totalPrice = 0.0;
            var batchShop: Array<ShopEntry> = shop.map(
                entry -> Reflect.copy(entry)
            );
            var availableXs = [for (x in 0...this.wid) x];
            var dirByX = new Map<Int, Int>();
            while (registeredMobs < batchSize) {
                batchShop = batchShop.filter(
                    entry -> entry.price <= batchPoints - totalPrice
                );
                if (batchShop.length == 0)
                    break;

                var chosenEntry = batchShop[M.randRange(
                    0, batchShop.length - 1
                )];
                totalPrice += chosenEntry.price;
                chosenEntry.price += chosenEntry.accumulativePrice ?? 0;

                var x = availableXs[M.randRange(
                    if (
                        this.waveId <= 3 &&
                        delay == 0.0 &&
                        chosenEntry.price >= 3
                    ) availableXs.length - 8 else 0,
                    availableXs.length
                )];
                availableXs.remove(x);
                availableXs.remove(x - 1);
                availableXs.remove(x + 1);

                var dir: Int;
                if (M.fabs(x - 10) > 6)
                    dir = 0;
                else if (M.fabs(dirByX[x]) > 0)
                    dir = dirByX[x];
                else
                    dir = M.randRange(-1, 1);

                if (dir == 0)
                    dir = if (x < this.wid * 0.5) 1 else -1;

                for (closeX in (x - 4)...(x + 5))
                    dirByX[closeX] = if (dirByX.exists(closeX)) 0 else dir;

                wave.registerEntity(
                    chosenEntry.createMob(
                        x, if (this.waveId <= 1) 6 else 4, dir
                    ),
                    delay
                );

                registeredMobs++;
            }
            points -= totalPrice * Math.log(registeredMobs + 1);
            delay += 3.5;
        }

        wave.start();
    }

    public function isValid(cx: Float, cy: Float) {
        return cx >= 0 && cx < wid && cy >= 0 && cy < hei;
    }

    public function coordId(x, y)
        return x + y * wid;

    public function hasColl(x: Int, y: Int) {
        return !isValid(x, y) ? true : collMap.get(coordId(x, y));
    }

    public function setColl(x, y, v: Bool) {
        collMap.set(coordId(x, y), v);
    }

    override public function update() {
        var game = Game.ME;
        baseTimeMul = game.getSlowMoFactor();
        super.update();
        for (e in people)
            e.anim.setGlobalSpeed(game.getSlowMoFactor());

        switch (waveId) {
            case 0, 1:
                if (!cd.hasSetS("smoke", 0.06))
                    game.fx.envSmoke();

                if (!cd.hasSetS("envInit", Const.INFINITE))
                    for (i in 0...30)
                        game.fx.envRain();

                if (!cd.hasSetS("env", 0.06))
                    game.fx.envRain();

            default:
                if (!cd.hasSetS("envInit", Const.INFINITE))
                    for (i in 0...30)
                        game.fx.envDust();

                if (!cd.hasSetS("env", 0.06))
                    game.fx.envDust();

                if (!cd.hasSetS("flash", 0.5))
                    Game.ME.fx.flashBangS(0x7B64DB, 0.07, 0.5);

                if (!cd.hasSetS("spot", 0.06))
                    for (i in 0...5)
                        Game.ME.fx.spotLight(
                            wid * Const.GRID * rnd(0, 1), rnd(20, 30));

                if (!cd.hasSetS("lazer", 0.06))
                    for (i in 0...5)
                        Game.ME.fx.lazer(wid * Const.GRID * rnd(0, 1));
        }
    }
}
