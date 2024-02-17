/**
    Singleton class for in-game debug console.
    Press '/' to open
**/
class Console extends h2d.Console {
    public static var ME: Console;

    var flags: Map<String, Bool>;

    public function new() {
        super(Assets.consoleFont);

        h2d.Console.HIDE_LOG_TIMEOUT = 5;
        ME = this;
        Main.ME.root.add(this, Const.UI_LAYER);
        dn.Lib.redirectTracesToH2dConsole(this);

        this.flags = new Map();

        #if debug
        this.addCommand(
            "set", [{name: "flag", t: AString}], function(flag: String) {
                this.set(flag, true);
                this.log('+ $flag', 0x80FF00);
        });

        this.addCommand(
            "unset", [{name: "flag", t: AString, opt: true}],
            function(?flag: String) {
                if (flag == null) {
                    this.log("Reset all.", 0xFF0000);
                    this.flags = new Map();
                } else {
                    this.log('- $flag', 0xFF8000);
                    this.set(flag, false);
                }
            });

        this.addAlias("+", "set");
        this.addAlias("-", "unset");

        this.addCommand("grid", [], function() {
            final level = Game.ME.level;
            var graphics = level.debug;
            graphics.endFill();
            graphics.lineStyle(1, 0xFFFF00, 0.4);
            for (cx in 0...level.wid) {
                graphics.moveTo(cx * Const.GRID, 0);
                graphics.lineTo(cx * Const.GRID, level.hei * Const.GRID);
            }
            for (cy in 0...level.hei) {
                graphics.moveTo(0, cy * Const.GRID);
                graphics.lineTo(level.wid * Const.GRID, cy * Const.GRID);
            }
        });

        this.addCommand("god", [], function() {
            Game.ME.hero.isInvulnerable = !Game.ME.hero.isInvulnerable;
            this.log('God Mode: ${Game.ME.hero.isInvulnerable}');
        });
        #end
    }

    public function set(flag: String, value: Bool)
        return this.flags.set(flag, value);

    public function has(flag: String)
        return this.flags.get(flag) == true;
}
