package states.editors;

#if android

import states.MusicBeatState;

class ChartingState extends MusicBeatState
{
	override function create()
	{
		super.create();
		// Chart Editor desativado no Android
	}
}

#else

import states.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.addons.ui.*;
import flixel.util.FlxColor;

import backend.Song;
import backend.Section;

import objects.Note;
import objects.StrumNote;
import objects.HealthIcon;
import objects.AttachedSprite;

import substates.Prompt;

class ChartingState extends MusicBeatState
{
	// =========================
	// VARIÁVEIS
	// =========================

	public static var curSec:Int = 0;
	public static var goToPlayState:Bool = false;

	var _song:SwagSong;
	var UI_box:FlxUITabMenu;

	// =========================
	// CREATE
	// =========================

	override function create()
	{
		super.create();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				events: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				gfVersion: 'gf',
				speed: 1,
				stage: 'stage'
			};
			PlayState.SONG = _song;
		}

		var bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.fromRGB(30, 30, 30));
		add(bg);

		createUI();
	}

	// =========================
	// UI
	// =========================

	function createUI()
	{
		var tabs = [
			{name: "Song", label: "Song"},
			{name: "Section", label: "Section"},
			{name: "Note", label: "Note"}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(300, 400);
		UI_box.x = 20;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
	}

	function addSongUI():Void
	{
		var tab = new FlxUI(null, UI_box);
		tab.name = "Song";

		var songName = new FlxUIInputText(10, 10, 200, _song.song, 8);
		tab.add(songName);

		var saveBtn = new FlxButton(10, 40, "Save", function()
		{
			trace("Save song");
		});
		tab.add(saveBtn);

		UI_box.addGroup(tab);
	}

	// =========================
	// UPDATE
	// =========================

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

#end
