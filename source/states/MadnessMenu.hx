package states;

import backend.Highscore;
import flixel.addons.display.FlxTiledSprite;
import options.OptionsState;
import flixel.math.FlxRect;
import openfl.display.BitmapData;
import flixel.addons.display.FlxBackdrop;
using states.MadnessMenu.SpriteHelper;

class MadnessMenu extends MusicBeatState
{
    // 🔒 Substitui o enum (EVITA CRASH)
    static inline var HOVER_OPTIONS:Int = 1;
    static inline var HOVER_OTHER:Int = 0;

    var hoverMode:Int = HOVER_OTHER;

    public static var mouseGraphic:BitmapData =
        BitmapData.fromFile('assets/shared/images/madnessmenu/mouse.png');

    var uniScale:Float;
    var currentSel:Int = 0;

    var baseButtons:FlxTypedGroup<FlxSprite>;
    var optionsButton:FlxSprite;
    var circles:FlxSpriteGroup;
    var storyButton:FlxSprite;
    var storyDropDown:StorySubMenu;

    override function create()
    {
        #if !FLX_NO_MOUSE
        FlxG.mouse.visible = true;
        FlxG.mouse.load(mouseGraphic, 0.5);
        #end

        FlxG.camera.antialiasing = ClientPrefs.data.antialiasing;
        persistentUpdate = true;

        var back = new FlxSprite(Paths.image('madnessmenu/back'));
        back.setGraphicSize(FlxG.width);
        back.updateHitbox();
        back.screenCenter(Y);
        back.y += 100;
        add(back);

        uniScale = back.scale.x;

        var silh = new FlxBackdrop(Paths.image('madnessmenu/siloets'), X, 20);
        silh.setScale(uniScale);
        silh.y = 300;
        silh.velocity.x = -50;
        silh.alpha = 0.3;
        add(silh);

        storyDropDown = new StorySubMenu();
        add(storyDropDown);

        baseButtons = new FlxTypedGroup<FlxSprite>();
        add(baseButtons);

        storyButton = makeButton('storymode');
        storyButton.setPosition(1169 * uniScale, 405 * uniScale);
        baseButtons.add(storyButton);

        storyDropDown.setPosition(storyButton.x + 40, storyButton.y - 320);

        var freeplayButton = makeButton('freeplay');
        freeplayButton.setPosition(storyButton.x + storyButton.width + 10, storyButton.y);
        baseButtons.add(freeplayButton);

        optionsButton = makeButton('options');
        optionsButton.setPosition(storyButton.x + storyButton.width + 10, 760 * uniScale);
        add(optionsButton);

        circles = new FlxSpriteGroup();
        add(circles);

        super.create();
        changeSel();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && hoverMode != HOVER_OPTIONS)
            changeSel(controls.UI_LEFT_P ? -1 : 1);

        if (controls.ACCEPT)
        {
            if (storyDropDown.open)
                storyDropDown.confirm();
            else
                confirmSel();
        }

        #if !FLX_NO_MOUSE
        for (i in baseButtons)
        {
            var id = baseButtons.members.indexOf(i);
            if (FlxG.mouse.overlaps(i) && FlxG.mouse.justPressed)
            {
                currentSel = id;
                confirmSel();
            }
        }

        if (FlxG.mouse.overlaps(optionsButton) && FlxG.mouse.justPressed)
            confirmSel();
        #end
    }

    function confirmSel()
    {
        FlxG.sound.play(Paths.sound('madness/select'));

        if (hoverMode == HOVER_OPTIONS)
        {
            MusicBeatState.switchState(new OptionsState());
            return;
        }

        switch (currentSel)
        {
            case 0:
                openStoryDropdown();
            case 1:
                MusicBeatState.switchState(new MadnessCredits());
        }
    }

    function openStoryDropdown()
    {
        storyDropDown.open = true;
        FlxTween.tween(storyDropDown, {y: storyButton.y}, 0.4, {ease: FlxEase.cubeOut});
    }

    function changeSel(v:Int = 0)
    {
        FlxG.sound.play(Paths.sound('madness/beep'));
        currentSel = FlxMath.wrap(currentSel + v, 0, baseButtons.length - 1);
        baseButtons.members[currentSel].animation.play('select');
    }

    function makeButton(path:String):FlxSprite
    {
        var spr = new FlxSprite();
        spr.frames = Paths.getSparrowAtlas("madnessmenu/" + path);
        spr.animation.addByPrefix('idle', path + '0');
        spr.animation.addByPrefix('confirm', path + ' confirm');
        spr.animation.addByPrefix('select', path + ' select');
        spr.animation.play('idle');
        spr.setScale(uniScale + 0.2);
        return spr;
    }
}
