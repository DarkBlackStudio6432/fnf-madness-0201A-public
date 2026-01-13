package states;

import backend.Highscore;
import flixel.addons.display.FlxTiledSprite;
import options.OptionsState;
import flixel.math.FlxRect;
import openfl.display.BitmapData;
import flixel.input.mouse.FlxMouseEvent;
import flixel.addons.display.FlxBackdrop;
using states.MadnessMenu.SpriteHelper;

enum Hovering {
    OPTIONS;
    ANYTHINGELSE;
}

class MadnessMenu extends MusicBeatState
{
    var hoverMode:Hovering = ANYTHINGELSE;

    public static var mouseGraphic:BitmapData = BitmapData.fromFile('assets/shared/images/madnessmenu/mouse.png');
    var uniScale:Float;

    var currentSel:Int = 0;
    var baseButtons:FlxTypedGroup<FlxSprite>;
    var optionsButton:FlxSprite;
    var circles:FlxSpriteGroup;
    var storyButton:FlxSprite;
    var storyDropDown:StorySubMenu;

    override function create()
    {
        Paths.sound("coming soon");

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

        var chars = [['hank','idle','100,300'],['gf','girlfriend','100,180'],['bf','bf','100,300']];
        var opt = FlxG.random.getObject(chars);
        var pos = opt[2].split(',');
        var char = new FlxAnimate(Std.parseFloat(pos[0]), Std.parseFloat(pos[1]), 'assets/shared/images/madnessmenu/${opt[0]}');
        char.anim.addBySymbol('i', opt[1], 24, true);
        char.anim.play('i');
        char.scale.set(0.6, 0.6);
        add(char);

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

        var topBar = new FlxSprite(Paths.image('madnessmenu/top bar'));
        topBar.setScale(uniScale);
        add(topBar);

        new FlxTimer().start(FlxG.random.float(0.5, 1.5), moveSquare, 3);

        circles = new FlxSpriteGroup();
        add(circles);

        super.create();
        changeSel();

        new FlxTimer().start(5, function(timer)
        {
            var circle = circles.recycle(FlxSprite);
            circle.loadGraphic(Paths.image('madnessmenu/circle'));
            circle.setScale(uniScale * 0.2);
            circle.alpha = 0.08;
            add(circle);

            var scaleTime = FlxG.random.float(7, 12);
            FlxTween.tween(circle.scale, {x: 2, y: 2}, scaleTime, {
                onComplete: function(_) circle.kill()
            });

            timer.reset(FlxG.random.float(6, 13));
        });
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && hoverMode != OPTIONS)
            changeSel(controls.UI_LEFT_P ? -1 : 1);

        if (controls.ACCEPT)
        {
            if (storyDropDown.open)
                storyDropDown.confirm();
            else
                confirmSel();
        }

        #if !FLX_NO_KEYBOARD
        if (FlxG.keys.justPressed.C)
            FlxG.switchState(new MadnessCredits());
        #end

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

    function moveSquare(?_)
    {
        var square = makeSquare();
        square.alpha = 0;

        new FlxTimer().start(FlxG.random.float(1, 3), function(_)
        {
            FlxTween.tween(square, {alpha: 0.25}, 1, {
                onComplete: function(_) square.destroy()
            });
        });
    }

    inline function makeSquare():FlxSprite
    {
        var size = Std.int(18 * uniScale);
        var square = new FlxSprite().makeGraphic(size, size, FlxColor.RED);
        add(square);
        return square;
    }

    function confirmSel()
    {
        FlxG.sound.play(Paths.sound('madness/select'));
        var button = hoverMode == OPTIONS ? optionsButton : baseButtons.members[currentSel];
        button.animation.play('confirm');

        if (hoverMode == OPTIONS)
            MusicBeatState.switchState(new OptionsState());
        else if (currentSel == 1)
            MusicBeatState.switchState(new MadnessCredits());
        else
            openStoryDropdown();
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
        spr.animation.addByPrefix('i', path + '0');
        spr.animation.addByPrefix('confirm', path + ' confirm');
        spr.animation.addByPrefix('select', path + ' select');
        spr.animation.play('i');
        spr.setScale(uniScale + 0.2);
        return spr;
    }
}
