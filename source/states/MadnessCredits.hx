package states;

import objects.Character;
import openfl.filters.GlowFilter;
import flixel.util.FlxGradient;
import objects.AttachedSprite;
import backend.PsychCamera;

@:structInit class Credit {
    public var name:String = '';
    public var quote:String = '';
    public var role:String = '';
    public var link:String = '';
}

class MadnessCredits extends MusicBeatState
{
    var curSel:Int = 0;

    var creditText:FlxTypedGroup<FlxText>;
    var credits:Array<Credit> = [
        {name: 'grave',quote: 'this mod is a disease',role: 'director, artist',link: 'https://x.com/konn_artist'},
        {name: 'vamazotz',quote: 'i fuckingf love hank j wimbleton',role: 'co-director, artist',link: 'https://x.com/vamazotz'},
        {name: 'jads',quote: 'get a bunch of bikes, and ride em around with your friends',role: 'composer',link: 'https://x.com/Aw3somejds'},
        {name: 'cval',quote: 'well hello everyone',role: 'charter, composer',link: 'https://x.com/cval_brown'},
        {name: 'punkett',quote: 'made everything',role: 'composer',link: 'https://x.com/_punkett'},
        {name: 'marstarbro',quote: "They just threw me in a group chat and 3 hours later, here's a pause theme",role: 'composer',link: 'https://x.com/MarstarMain'},
        {name: 'river',quote: 'hold the crust',role: 'composer',link: 'https://x.com/rivermusic_'},
        {name: 'shayreyez',quote: 'i need to plap thick booba mmm futa porn',role: 'artist',link: 'https://x.com/ShayReyZed'},
        {name: 'yabo',quote: 'i really rwally like gruntfriend',role: 'charter, artist',link: 'https://x.com/yaboigp'},
        {name: 'data5',quote: 'well',role: 'coder',link: 'https://x.com/_data5'},
        {name: 'smokey5',quote: 'fuck data fuuuuuuuuuuuuuuuuuuuck help me think of a quote',role: 'coder',link: 'https://x.com/Smokey_5_'},
        {name: 'jayythunder',quote: 'NOTHING BUT BANGERS, AND I KNOW BANGERS',role: 'chromatic',link: 'https://x.com/ThunderJayy'},
        {name: 'laeko',quote: 'I love my ladies like I looove burgers!',role: 'artist',link: 'https://x.com/LaekoGah'},
        {name: 'infry',quote: 'my belly is so big and round',role: 'saved the mod',link: 'https://x.com/Infry20'},
        {name: 'mr krinkles',quote: 'thank u for making madness combat',role: 'made madness combat',link: 'https://x.com/MRKrinkels'},
    ];

    var displayedQuote:FlxText;
    var displayedRole:FlxText;

    var rim:FlxSprite;
    var arrow:AttachedSprite;
    var glow:AttachedSprite;

    var everyoneButInfry:Character;
    var character:FlxSprite;

    override function create()
    {
        persistentUpdate = true;
        super.create();

        glow = new AttachedSprite('madnessmenu/credits/glows');
        glow.copyAlpha = false;
        glow.alpha = 0.7;
        add(glow);

        creditText = new FlxTypedGroup();
        add(creditText);

        arrow = new AttachedSprite('madnessmenu/credits/arrow');
        add(arrow);

        for (k => i in credits)
        {
            var text = new FlxText(20, 0, 0, i.name.toUpperCase(), 61);
            text.y = (text.height + 25) * k;
            text.font = Paths.font('impact.ttf');
            text.color = FlxColor.RED;
            creditText.add(text);
        }

        rim = new FlxSprite(Paths.image('madnessmenu/credits/grey'));
        rim.scale.set(1.1, 1.1);
        rim.updateHitbox();
        add(rim);
        rim.scrollFactor.set();

        everyoneButInfry = new Character(650, 140, 'creditChar');
        add(everyoneButInfry);
        everyoneButInfry.scrollFactor.set();

        character = new FlxSprite();
        character.frames = Paths.getSparrowAtlas('madnessmenu/credits/infry');
        character.animation.addByPrefix('infry', 'infry', 24, false);
        add(character);
        character.scrollFactor.set();

        displayedRole = new FlxText(0, 0, FlxG.width - 25, '', 60);
        displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
        displayedRole.alignment = RIGHT;
        displayedRole.scale.y = 1.5;
        add(displayedRole);

        displayedQuote = new FlxText(0, 0, 0, '', 40);
        displayedQuote.font = Paths.font('impact.ttf');
        displayedQuote.color = FlxColor.RED;
        add(displayedQuote);

        changeSel();
    }

    var holdTime:Float = 0;
    var scrollLerp:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        // 🔒 SCROLL SEGURO (DESKTOP + MOBILE)
        #if !FLX_NO_MOUSE
        if (controls.UI_DOWN_P || controls.UI_UP_P || FlxG.mouse.wheel != 0)
        {
            holdTime = 0;
            changeSel(FlxG.mouse.wheel == 0 ? (controls.UI_DOWN_P ? 1 : -1) : -FlxG.mouse.wheel);
        }
        #else
        if (controls.UI_DOWN_P || controls.UI_UP_P)
        {
            holdTime = 0;
            changeSel(controls.UI_DOWN_P ? 1 : -1);
        }
        #end

        if (controls.BACK)
            MusicBeatState.switchState(new MadnessMenu());

        // 🔒 CLICK / ACCEPT SEGURO
        if (
            controls.ACCEPT
            #if !FLX_NO_MOUSE
            || FlxG.mouse.justPressed
            #end
        )
        {
            CoolUtil.browserLoad(credits[curSel].link);
        }

        FlxG.camera.scroll.y = FlxMath.lerp(
            FlxG.camera.scroll.y,
            scrollLerp,
            0.4 * 60 * elapsed
        );
    }

    function changeSel(s:Int = 0)
    {
        curSel = FlxMath.wrap(curSel + s, 0, credits.length - 1);

        var curText = creditText.members[curSel];
        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
        displayedRole.text = credits[curSel].role.toUpperCase();

        scrollLerp = (curText.y + curText.height / 2) - FlxG.height / 2;

        arrow.sprTracker = curText;
        glow.sprTracker = curText;
    }
}
