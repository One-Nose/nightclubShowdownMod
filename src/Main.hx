/**
    One-at-a-time class for the app
**/
class Main extends dn.Process {
    public static final BACKGROUND = 0x000000;
    public static var ME: Main;

    public final console: Console;
    public final cached: h2d.Object;

    /** A black screen that fades in and out on transition **/
    var black: h2d.Bitmap;

    public function new() {
        super();

        ME = this;
        keyPresses = new Map();

        this.createRoot(Boot.ME.s2d);

        this.cached = new h2d.Object(this.root);
        this.cached.filter = new h2d.filter.ColorMatrix();

        hxd.Res.initEmbed();

        hxd.snd.Manager.get(); // force sound init (not required?)

        Assets.init();
        console = new Console();

        // Pause on unfocus
        new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.font);

        hxd.Timer.wantedFPS = Const.FPS;

        this.toggleFullscreen();

        this.black = new h2d.Bitmap(
            h2d.Tile.fromColor(BACKGROUND, 1, 1), this.root
        );
        this.black.visible = false;

        hxd.Timer.skip();
        this.delayer.addF(() -> this.restartGame(), 1);

        this.onResize();
    }

    public function isTransitioning()
        return this.cd.has("transition");

    /** Keys that are already down and can't be pressed until raised **/
    final keyPresses: Map<Int, Bool>;

    public function keyPressed(k: Int) {
        if (this.console.isActive() || this.isTransitioning())
            return false;

        if (this.keyPresses.exists(k))
            return false;

        this.keyPresses.set(k, true);
        return hxd.Key.isDown(k);
    }

    /**
        Fades transition blackness in or out,
        then calls `callback`
    **/
    public function fadeBlack(
        fadeIn: Bool, ?seconds: Float, ?callback: () -> Void
    ) {
        if (fadeIn) {
            this.cd.setS("transition", Const.INFINITE);

            this.black.visible = true;
            this.tw
                .createS(this.black.alpha, 0 > 1, seconds ?? 0.6)
                .onEnd = function() {
                    if (callback != null)
                        callback();
                };
        } else {
            this.tw
                .createS(this.black.alpha, 0, seconds ?? 0.3)
                .onEnd = function() {
                    this.black.visible = false;
                    if (callback != null)
                        callback();

                    this.cd.unset("transition");
                };
        }
    }

    var fullscreen = false;

    public function toggleFullscreen() {
        #if hl
        final window = hxd.Window.getInstance();
        fullscreen = !fullscreen;
        window.displayMode = if (fullscreen) Borderless else Windowed;
        #end
    }

    override public function onResize() {
        super.onResize();

        Const.SCALE = M.floor(this.w() / (20 * Const.GRID));
        this.cached.scaleX = this.cached.scaleY = Const.SCALE;
        this.black.scaleX = Boot.ME.s2d.width;
        this.black.scaleY = Boot.ME.s2d.height;
    }

    override public function onDispose() {
        super.onDispose();
        if (ME == this)
            ME = null;
    }

    public function restartGame(?history: Array<Game.HistoryEntry>) {
        if (Game.ME != null) {
            this.fadeBlack(true, function() {
                Game.ME.destroy();
                Assets.playMusic(false);

                this.delayer.addS(function() {
                    new Game(new h2d.Object(this.cached), history);
                    this.fadeBlack(true, 0.4);
                    this.fadeBlack(false);
                }, 0.5);
            });
        } else {
            new Game(new h2d.Object(this.cached), history);
            this.fadeBlack(true, 0.4);
            this.fadeBlack(false);
            Assets.playMusic(false);
        }
    }

    override function postUpdate() {
        super.postUpdate();

        this.root.over(this.black);

        for (key in keyPresses.keys())
            if (!hxd.Key.isDown(key))
                keyPresses.remove(key);
    }

    override function update() {
        super.update();
        Assets.gameElements.tmod = this.tmod * Boot.ME.speed;
    }
}
