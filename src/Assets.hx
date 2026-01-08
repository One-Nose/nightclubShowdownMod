import dn.heaps.Sfx;

/**
    Static class to manage assets
**/
class Assets {
    public static final SFX = dn.heaps.assets.SfxDirectory.load("sfx", true);
    public static var gameElements: SpriteLib;
    public static var font: h2d.Font;
    public static var consoleFont: h2d.Font;
    public static var musicIn: Sfx;
    public static var musicOut: Sfx;

    public static function init() {
        font = hxd.Res.minecraftiaOutline.toFont();
        consoleFont = font.clone();
        consoleFont.resizeTo(20);

        Sfx.setGroupVolume(0, 1);
        Sfx.setGroupVolume(1, 0.7);

        #if hl
        musicIn = new Sfx(hxd.Res.music.musicIn);
        musicOut = new Sfx(hxd.Res.music.musicOut);
        #else
        musicIn = new Sfx(hxd.Res.music.f_musicIn);
        musicOut = new Sfx(hxd.Res.music.f_musicOut);
        #end

        gameElements = dn.heaps.assets.Atlas.load("gameElements.atlas");
        gameElements.defineAnim("heroAimShoot", "0(10), 1(10)");
        gameElements.defineAnim("heroGrabBlindShoot", "0(4), 1(10)");
        gameElements.defineAnim("heroBlindShoot", "0(4), 1(10)");
        gameElements.defineAnim("heroThrowGrenade", "0(4), 1(10)");
        gameElements.defineAnim("heroHit", "0(8)");
        gameElements.defineAnim("heroKick", "0(20), 1(5)");
        gameElements.defineAnim("heroDeathFly", "0(30), 1(9999)");
        gameElements.defineAnim("heroRun", "0(6),1(4), 2(4), 3(6), 4(4), 5(4)");

        gameElements.defineAnim("basicGunAimShoot", "0(10), 1(10)");
        gameElements.defineAnim("basicGunBlindShoot", "0(4), 1(10)");
        gameElements.defineAnim("basicGunHit", "0(8)");
        gameElements.defineAnim("basicGunDeathFly", "0(30), 1(9999)");
        gameElements.defineAnim("basicGunGrab", "0(15), 1(10)");
        gameElements.defineAnim(
            "basicGunRun", "0(6),1(4), 2(4), 3(6), 4(4), 5(4)"
        );

        gameElements.defineAnim("grenaderAimShoot", "0(10), 1(10)");
        gameElements.defineAnim("grenaderBlindShoot", "0(4), 1(10)");
        gameElements.defineAnim("grenaderThrowGrenade", "0(4), 1(10)");
        gameElements.defineAnim("grenaderHit", "0(8)");
        gameElements.defineAnim("grenaderDeathFly", "0(30), 1(9999)");
        gameElements.defineAnim("grenaderGrab", "0(15), 1(10)");
        gameElements.defineAnim(
            "grenaderRun", "0(6),1(4), 2(4), 3(6), 4(4), 5(4)"
        );

        gameElements.defineAnim("heavyAimShoot", "0(10), 1(10)");
        gameElements.defineAnim("heavyBlindShoot", "0(4), 1(10)");
        gameElements.defineAnim("heavyHit", "0(8)");
        gameElements.defineAnim("heavyDeathFly", "0(30), 1(9999)");
        // gameElements.defineAnim("heavyGrab","0(15), 1(10)");
        gameElements.defineAnim(
            "heavyRun", "0(6),1(4), 2(4), 3(6), 4(4), 5(4)"
        );

        gameElements.defineAnim("sniperAimShoot", "0(10), 1(10)");
        gameElements.defineAnim("sniperHit", "0(8)");
        gameElements.defineAnim("sniperDeathFly", "0(30), 1(9999)");
        gameElements.defineAnim("sniperGrab", "0(15), 1(10)");
        gameElements.defineAnim(
            "sniperRun", "0(6),1(4), 2(4), 3(6), 4(4), 5(4)"
        );

        gameElements.defineAnim("dancingA", "0-1(10)");
        gameElements.defineAnim("dancingB", "0-1(10)");
        gameElements.defineAnim("dancingC", "0-1(10)");

        // tiles = dn.heaps.slib.assets.Atlas.load("tiles.atlas");
    }

    public static function playMusic(isIn: Bool) {
        musicIn.stop();
        musicOut.stop();
        if (isIn)
            musicIn.playOnGroup(1, true);
        else
            musicOut.playOnGroup(1, true);
    }
}
